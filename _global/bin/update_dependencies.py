#!/usr/bin/env python3
"""
Interactive Dependency Version Manager for Biocentral Projects.

Collects dependencies from pyproject.toml across subprojects,
queries PyPI for the latest version and release dates (disallowing versions
younger than 1 week by default), caches user decisions across projects,
supports previous/skip navigation, and updates pyproject.toml files while
preserving comments, structure, and formatting.
"""

from __future__ import annotations

import argparse
import os
import re
import sys
from dataclasses import dataclass, field
from datetime import datetime, timezone, timedelta
from pathlib import Path
from typing import Dict, List, Optional, Tuple, Any

import requests
try:
    import tomllib
except ImportError:
    try:
        import tomli as tomllib  # type: ignore
    except ImportError:
        tomllib = None  # type: ignore

try:
    import tomlkit
except ImportError:
    tomlkit = None  # type: ignore
from packaging.requirements import Requirement, InvalidRequirement
from packaging.specifiers import SpecifierSet, InvalidSpecifier
from packaging.utils import canonicalize_name
from packaging.version import Version, InvalidVersion, parse as parse_version

# Minimum release age policy: 7 days
MIN_RELEASE_AGE_DAYS = 7

# Known development / testing packages
KNOWN_DEV_PACKAGES = {
    "pytest",
    "pytest-cov",
    "pytest-asyncio",
    "pytest-mock",
    "pytest-xdist",
    "pytest-sugar",
    "pytest-benchmark",
    "coverage",
    "mypy",
    "ruff",
    "black",
    "flake8",
    "flake8-bugbear",
    "isort",
    "pre-commit",
    "tox",
    "pylint",
    "deptry",
    "bandit",
    "safety",
    "pip-tools",
    "pipdeptree",
    "build",
    "twine",
    "wheel",
    "sphinx",
    "sphinx-rtd-theme",
    "mkdocs",
    "mkdocs-material",
    "responses",
    "freezegun",
    "respx",
    "httpx-mock",
}


def is_internal_dependency(name: str) -> bool:
    """Checks whether the package is an internal repo package (biocentral, biotrainer, etc.)."""
    canon = canonicalize_name(name)
    if canon == "biocentral" or canon.startswith("biocentral-") or canon.startswith("biocentral_"):
        return True
    if canon == "biotrainer" or canon.startswith("biotrainer-") or canon.startswith("biotrainer_"):
        return True
    return False


def is_git_dependency(raw_entry: str, req: Optional[Requirement] = None) -> bool:
    """Checks whether a dependency entry is a git / URL dependency."""
    cleaned = raw_entry.strip()
    if "@ git+" in cleaned or "@ git@" in cleaned or "@ http" in cleaned or "git+" in cleaned or ".git@" in cleaned:
        return True
    if req is not None and req.url:
        return True
    return False


def is_dev_dependency(item: DependencyItem) -> bool:
    """Checks whether a dependency is a development/testing dependency."""
    if item.section_name.startswith("dependency-groups"):
        return True
    if item.section_name.startswith("optional-dependencies."):
        group = item.section_name.split(".", 1)[1].lower()
        if any(dev_kw in group for dev_kw in ("dev", "test", "lint", "typing", "doc", "ci", "check", "style")):
            return True
    canon = item.canonical_name
    if (
        canon in KNOWN_DEV_PACKAGES
        or canon.startswith("pytest-")
        or canon.startswith("types-")
        or canon.startswith("mypy-")
    ):
        return True
    return False


def normalize_marker(marker_str: str) -> str:
    """Ensures string literals inside environment markers use single quotes."""
    if not marker_str:
        return ""
    return re.sub(r'"([^"]*)"', r"'\1'", marker_str)


def order_specifiers(spec_str: str) -> str:
    """
    Orders version specifiers consistently:
    Lower bounds (>=, >) first, then upper bounds (<, <=), then others (~=, ==, !=).
    e.g. '<3.0.0,>=2.0.0' -> '>=2.0.0,<3.0.0'
    """
    if not spec_str:
        return ""
    try:
        spec_set = SpecifierSet(spec_str)
    except Exception:
        return spec_str

    specs = list(spec_set)
    if len(specs) <= 1:
        return spec_str

    def spec_key(s):
        op = s.operator
        try:
            v = parse_version(s.version)
        except Exception:
            v = s.version
        if op in (">=", ">"):
            return (0, v)
        elif op in ("<=", "<"):
            return (1, v)
        elif op == "~=":
            return (2, v)
        elif op == "==":
            return (3, v)
        else:
            return (4, v)

    sorted_specs = sorted(specs, key=spec_key)
    return ",".join(str(s) for s in sorted_specs)


def validate_version_input(user_input: str) -> Tuple[bool, Optional[str]]:
    """
    Validates user entered version specifier or range.
    Enforces format: lower bound first (>=X.X.X,<Y.Y.Y).
    Returns (is_valid, error_message).
    """
    val = user_input.strip()
    if not val:
        return True, None

    # 1. Caret format
    if val.startswith("^"):
        v_part = val[1:].strip()
        try:
            parse_version(v_part)
            return True, None
        except InvalidVersion:
            return False, f"Invalid version in caret shortcut: '{val}'. Expected e.g. '^2.0.0'"

    # 2. Bare version: e.g. 1.2.3
    if re.match(r"^\d+(\.\d+)*(\.[a-zA-Z0-9]+)?$", val):
        return True, None

    # 3. Check if full requirement was typed
    spec_to_check = val
    try:
        req = Requirement(val)
        spec_to_check = str(req.specifier) if req.specifier else ""
    except InvalidRequirement:
        pass

    # 4. Check for range order in raw input string
    if "," in val:
        spec_text = val
        if ";" in spec_text:
            spec_text = spec_text.split(";", 1)[0].strip()
        name_match = re.match(r"^[A-Za-z0-9_.\-]+(\[[^\]]*\])?(.*)$", spec_text)
        if name_match:
            spec_text = name_match.group(2).strip()

        parts = [p.strip() for p in spec_text.split(",") if p.strip()]
        has_lower = any(p.startswith(">=") or p.startswith(">") for p in parts)
        has_upper = any(p.startswith("<=") or p.startswith("<") for p in parts)

        if has_lower and has_upper:
            # First part must be the lower bound
            if not (parts[0].startswith(">=") or parts[0].startswith(">")):
                return (
                    False,
                    f"Faulty format: Lower bound must come first in version range (e.g. '>=2.0.0,<3.0.0', not '{val}').",
                )

    # 5. Validate specifier set syntax
    try:
        SpecifierSet(spec_to_check if spec_to_check else val)
    except (InvalidSpecifier, ValueError):
        return (
            False,
            f"Invalid version specifier: '{val}'. Expected format e.g. '>=2.0.0,<3.0.0', '==1.2.3', or '^1.2.3'",
        )

    return True, None


# Terminal Styling Helpers
class Colors:
    CYAN = "\033[96m"
    BLUE = "\033[94m"
    GREEN = "\033[92m"
    YELLOW = "\033[93m"
    RED = "\033[91m"
    MAGENTA = "\033[95m"
    BOLD = "\033[1m"
    DIM = "\033[2m"
    UNDERLINE = "\033[4m"
    RESET = "\033[0m"

    @classmethod
    def enabled(cls) -> bool:
        return sys.stdout.isatty() and not os.environ.get("NO_COLOR")

    @classmethod
    def c(cls, text: str, color: str) -> str:
        return f"{color}{text}{cls.RESET}" if cls.enabled() else str(text)


@dataclass
class ReleaseInfo:
    version_str: str
    version: Version
    upload_time: datetime
    age_days: int
    is_disallowed: bool  # True if < 7 days old


@dataclass
class PyPIPackageInfo:
    name: str
    latest: Optional[ReleaseInfo] = None
    latest_eligible: Optional[ReleaseInfo] = None
    all_releases: List[ReleaseInfo] = field(default_factory=list)
    error: Optional[str] = None


@dataclass
class DependencyItem:
    project_path: Path
    project_name: str
    section_name: str
    section_key_path: List[str]
    index: int
    raw_text: str
    req_name: str
    canonical_name: str
    specifier: str
    extras: str = ""
    marker: str = ""
    url: Optional[str] = None
    is_valid_req: bool = True
    new_specifier: Optional[str] = None
    new_raw_text: Optional[str] = None

    @property
    def current_version_display(self) -> str:
        if self.url:
            return f"(url/git: {self.url})"
        if self.specifier:
            return self.specifier
        return "(no version constraint)"


@dataclass
class DependencyDecision:
    canonical_name: str
    package_name: str
    specifier: str
    source_project: str
    raw_specifier_input: str


class PyPIClient:
    """Queries PyPI API with caching and 7-day age validation."""

    def __init__(self, timeout: float = 10.0, min_age_days: int = MIN_RELEASE_AGE_DAYS):
        self.timeout = timeout
        self.min_age_days = min_age_days
        self._cache: Dict[str, PyPIPackageInfo] = {}

    def get_package_info(self, package_name: str, now: Optional[datetime] = None) -> PyPIPackageInfo:
        canonical = canonicalize_name(package_name)
        if canonical in self._cache:
            return self._cache[canonical]

        if now is None:
            now = datetime.now(timezone.utc)

        info = self._fetch_from_pypi(package_name, now)
        self._cache[canonical] = info
        return info

    def _fetch_from_pypi(self, package_name: str, now: datetime) -> PyPIPackageInfo:
        url = f"https://pypi.org/pypi/{package_name}/json"
        try:
            resp = requests.get(url, timeout=self.timeout)
            if resp.status_code == 404:
                return PyPIPackageInfo(name=package_name, error="Package not found on PyPI (404)")
            resp.raise_for_status()
            data = resp.json()
        except Exception as e:
            return PyPIPackageInfo(name=package_name, error=f"PyPI request failed: {e}")

        releases_data = data.get("releases", {})
        parsed_releases: List[ReleaseInfo] = []

        for v_str, files in releases_data.items():
            if not files:
                continue
            try:
                v = parse_version(v_str)
                # Ignore pre-releases or dev releases by default unless no standard releases
                if v.is_prerelease or v.is_devrelease:
                    continue
            except InvalidVersion:
                continue

            # Find earliest/first upload timestamp among files for this release
            upload_dt: Optional[datetime] = None
            for file_info in files:
                iso_time = file_info.get("upload_time_iso_8601") or file_info.get("upload_time")
                if iso_time:
                    try:
                        dt = datetime.fromisoformat(iso_time.replace("Z", "+00:00"))
                        if upload_dt is None or dt < upload_dt:
                            upload_dt = dt
                    except (ValueError, TypeError):
                        pass

            if upload_dt is None:
                continue

            # Ensure timezone-aware
            if upload_dt.tzinfo is None:
                upload_dt = upload_dt.replace(tzinfo=timezone.utc)

            age = now - upload_dt
            age_days = max(0, age.days)
            is_disallowed = age < timedelta(days=self.min_age_days)

            parsed_releases.append(
                ReleaseInfo(
                    version_str=v_str,
                    version=v,
                    upload_time=upload_dt,
                    age_days=age_days,
                    is_disallowed=is_disallowed,
                )
            )

        if not parsed_releases:
            return PyPIPackageInfo(name=package_name, error="No valid releases with upload date found on PyPI")

        parsed_releases.sort(key=lambda r: r.version)
        latest = parsed_releases[-1]
        eligible = [r for r in parsed_releases if not r.is_disallowed]
        latest_eligible = eligible[-1] if eligible else None

        return PyPIPackageInfo(
            name=package_name,
            latest=latest,
            latest_eligible=latest_eligible,
            all_releases=parsed_releases,
        )


class ProjectScanner:
    """Discovers pyproject.toml files and collects dependency items."""

    IGNORE_DIRS = {
        ".git",
        ".venv",
        "venv",
        "env",
        ".env",
        "node_modules",
        "build",
        "dist",
        "__pycache__",
        ".tox",
        ".pytest_cache",
        ".mypy_cache",
        ".idea",
        ".vscode",
        ".junie",
        "exotox_reproduction",
        "exotox-reproduction",
    }

    def __init__(self, root_dir: Path):
        self.root_dir = root_dir.resolve()

    def find_all_projects(self) -> List[Path]:
        toml_files: List[Path] = []
        for root, dirs, files in os.walk(self.root_dir, topdown=True, followlinks=False):
            # Prune ignored directories in-place
            dirs[:] = [
                d
                for d in dirs
                if d not in self.IGNORE_DIRS
                and not d.startswith(".")
                and d not in ("exotox_reproduction", "exotox-reproduction")
            ]
            if any(part in ("exotox_reproduction", "exotox-reproduction") for part in Path(root).parts):
                continue
            if "pyproject.toml" in files:
                toml_files.append(Path(root) / "pyproject.toml")

        # Sort with root pyproject.toml first, then alphabetical by relative path
        def sort_key(p: Path) -> Tuple[int, str]:
            rel = p.relative_to(self.root_dir).as_posix()
            if rel == "pyproject.toml":
                return (0, "")
            return (1, rel)

        return sorted(toml_files, key=sort_key)

    @classmethod
    def collect_dependencies(cls, toml_path: Path, root_dir: Path) -> List[DependencyItem]:
        with open(toml_path, "r", encoding="utf-8") as f:
            content = f.read()

        if tomlkit is not None:
            doc = tomlkit.parse(content)
        elif tomllib is not None:
            doc = tomllib.loads(content)
        else:
            raise RuntimeError("Neither tomlkit nor tomllib is available.")

        rel_path = toml_path.relative_to(root_dir)
        proj_name = (
            doc.get("project", {}).get("name")
            or (rel_path.parent.name if rel_path.parent.name else rel_path.as_posix())
        )

        if str(proj_name) in ("exotox_reproduction", "exotox-reproduction") or any(
            part in ("exotox_reproduction", "exotox-reproduction") for part in toml_path.parts
        ):
            return []

        items: List[DependencyItem] = []

        # 1. [project.dependencies]
        if "project" in doc and "dependencies" in doc["project"]:
            deps = doc["project"]["dependencies"]
            if isinstance(deps, list):
                for idx, dep in enumerate(deps):
                    item = cls._parse_dependency_entry(
                        toml_path=toml_path,
                        proj_name=str(proj_name),
                        section_name="dependencies",
                        key_path=["project", "dependencies"],
                        index=idx,
                        raw_entry=str(dep),
                    )
                    if item:
                        items.append(item)

        # 2. [project.optional-dependencies]
        if "project" in doc and "optional-dependencies" in doc["project"]:
            opt = doc["project"]["optional-dependencies"]
            if hasattr(opt, "items"):
                for group_name, group_deps in opt.items():
                    if isinstance(group_deps, list):
                        for idx, dep in enumerate(group_deps):
                            item = cls._parse_dependency_entry(
                                toml_path=toml_path,
                                proj_name=str(proj_name),
                                section_name=f"optional-dependencies.{group_name}",
                                key_path=["project", "optional-dependencies", group_name],
                                index=idx,
                                raw_entry=str(dep),
                            )
                            if item:
                                items.append(item)

        # 3. [dependency-groups]
        if "dependency-groups" in doc:
            dep_groups = doc["dependency-groups"]
            if hasattr(dep_groups, "items"):
                for group_name, group_deps in dep_groups.items():
                    if isinstance(group_deps, list):
                        for idx, dep in enumerate(group_deps):
                            item = cls._parse_dependency_entry(
                                toml_path=toml_path,
                                proj_name=str(proj_name),
                                section_name=f"dependency-groups.{group_name}",
                                key_path=["dependency-groups", group_name],
                                index=idx,
                                raw_entry=str(dep),
                            )
                            if item:
                                items.append(item)

        return items

    @classmethod
    def _parse_dependency_entry(
        cls,
        toml_path: Path,
        proj_name: str,
        section_name: str,
        key_path: List[str],
        index: int,
        raw_entry: str,
    ) -> Optional[DependencyItem]:
        cleaned = raw_entry.strip()
        if not cleaned or cleaned.startswith("#"):
            return None

        if is_git_dependency(cleaned):
            return None

        try:
            req = Requirement(cleaned)
            if is_git_dependency(cleaned, req):
                return None
            if is_internal_dependency(req.name):
                return None

            extras_str = f"[{','.join(sorted(req.extras))}]" if req.extras else ""
            marker_str = normalize_marker(f"; {req.marker}") if req.marker else ""
            spec_str = order_specifiers(str(req.specifier))
            return DependencyItem(
                project_path=toml_path,
                project_name=proj_name,
                section_name=section_name,
                section_key_path=key_path,
                index=index,
                raw_text=raw_entry,
                req_name=req.name,
                canonical_name=canonicalize_name(req.name),
                specifier=spec_str,
                extras=extras_str,
                marker=marker_str,
                url=req.url,
                is_valid_req=True,
            )
        except InvalidRequirement:
            # Fallback for non-standard requirement strings
            name_match = re.match(r"^([A-Za-z0-9_.\-]+)", cleaned)
            name = name_match.group(1) if name_match else cleaned
            if is_internal_dependency(name):
                return None
            return DependencyItem(
                project_path=toml_path,
                project_name=proj_name,
                section_name=section_name,
                section_key_path=key_path,
                index=index,
                raw_text=raw_entry,
                req_name=name,
                canonical_name=canonicalize_name(name),
                specifier="",
                is_valid_req=False,
            )


def format_new_requirement_string(
    item: DependencyItem,
    new_specifier_input: str,
) -> Tuple[str, str]:
    """
    Constructs the updated requirement string based on user input,
    preserving extras and environment markers.
    Always orders version ranges (>=X.X.X,<Y.Y.Y) and uses single quotes in markers.
    Returns (new_specifier, new_full_raw_text).
    """
    user_input = new_specifier_input.strip()

    # Check if user entered a full requirement string (e.g., 'package>=1.0.0')
    try:
        parsed_req = Requirement(user_input)
        # If user typed full requirement for this package or compatible
        if canonicalize_name(parsed_req.name) == item.canonical_name:
            spec = order_specifiers(str(parsed_req.specifier))
            extras = f"[{','.join(sorted(parsed_req.extras))}]" if parsed_req.extras else item.extras
            marker = normalize_marker(f"; {parsed_req.marker}") if parsed_req.marker else normalize_marker(item.marker)
            full_str = f"{parsed_req.name}{extras}{spec}{marker}"
            return spec, full_str
    except InvalidRequirement:
        pass

    # Normalize version range shortcuts:
    # 1. Semver caret: ^1.2.3 -> >=1.2.3,<2.0.0 (or ^0.2.3 -> >=0.2.3,<0.3.0)
    if user_input.startswith("^"):
        v_part = user_input[1:].strip()
        try:
            v = parse_version(v_part)
            if v.major > 0:
                spec = f">={v_part},<{v.major + 1}.0.0"
            elif v.minor is not None and v.minor > 0:
                spec = f">={v_part},<0.{v.minor + 1}.0"
            else:
                spec = f">={v_part}"
        except InvalidVersion:
            spec = user_input
    # 2. Bare version: 1.2.3 -> ==1.2.3
    elif re.match(r"^\d+(\.\d+)*(\.[a-zA-Z0-9]+)?$", user_input):
        spec = f"=={user_input}"
    else:
        spec = user_input

    # Ensure specifier is ordered
    spec = order_specifiers(spec)
    marker = normalize_marker(item.marker)

    # Build full requirement string
    full_str = f"{item.req_name}{item.extras}{spec}{marker}"
    return spec, full_str


class DependencyManagerSession:
    """Manages the interactive navigation, decision caching, and applying changes."""

    def __init__(
        self,
        root_dir: Path,
        pypi_client: Optional[PyPIClient] = None,
        auto_accept_cached: bool = False,
    ):
        self.root_dir = root_dir.resolve()
        self.pypi_client = pypi_client or PyPIClient()
        self.auto_accept_cached = auto_accept_cached

        # Global decision cache: canonical_name -> DependencyDecision
        self.decisions: Dict[str, DependencyDecision] = {}
        # Per-item staged decisions: item_idx -> (new_specifier, new_raw_text)
        self.staged_changes: Dict[int, Tuple[str, str]] = {}
        self.items: List[DependencyItem] = []

    def load_all_items(self, target_project: Optional[str] = None) -> List[DependencyItem]:
        scanner = ProjectScanner(self.root_dir)
        proj_files = scanner.find_all_projects()

        if target_project:
            target_clean = target_project.strip().strip("/").lower()
            filtered = []
            for p in proj_files:
                rel = p.relative_to(self.root_dir).as_posix().lower()
                parent_name = p.parent.name.lower()
                if target_clean in ("root", "monorepo") and rel == "pyproject.toml":
                    filtered.append(p)
                elif rel == target_clean or target_clean == parent_name or target_clean in rel.split("/"):
                    filtered.append(p)
            proj_files = filtered

        self.items = []
        for p in proj_files:
            self.items.extend(ProjectScanner.collect_dependencies(p, self.root_dir))
        return self.items

    def run_interactive(self, input_func=input, print_func=print) -> bool:
        """
        Runs the interactive loop over all dependencies with previous/skip navigation.
        Returns True if changes were confirmed and applied, False if aborted.
        """
        if not self.items:
            print_func(Colors.c("No dependencies found to process.", Colors.YELLOW))
            return True

        current_idx = 0
        total_items = len(self.items)

        print_func(Colors.c("\n" + "=" * 70, Colors.CYAN))
        print_func(Colors.c("  Biocentral Dependency Version Manager", Colors.BOLD + Colors.CYAN))
        print_func(Colors.c(f"  Found {total_items} dependencies across projects in {self.root_dir}", Colors.DIM))
        print_func(Colors.c("  Policy: Versions younger than 7 days are disallowed.", Colors.DIM))
        print_func(Colors.c("=" * 70 + "\n", Colors.CYAN))

        while 0 <= current_idx < total_items:
            item = self.items[current_idx]
            rel_proj = item.project_path.relative_to(self.root_dir).as_posix()

            print_func(Colors.c("-" * 70, Colors.DIM))
            progress_str = f"[{current_idx + 1}/{total_items}]"
            proj_str = f"Project: {Colors.c(item.project_name, Colors.BOLD)} ({rel_proj})"
            sec_str = f"Section: {Colors.c(item.section_name, Colors.CYAN)}"
            print_func(f"{Colors.c(progress_str, Colors.BOLD + Colors.MAGENTA)} {proj_str} | {sec_str}")
            print_func(f"Dependency: {Colors.c(item.req_name + item.extras, Colors.BOLD + Colors.GREEN)}")
            print_func(f"Current version constraint: {Colors.c(item.current_version_display, Colors.YELLOW)}")
            if item.marker:
                print_func(f"Environment marker: {Colors.c(item.marker, Colors.DIM)}")

            # Check PyPI (or retrieve from cache)
            pypi_info: Optional[PyPIPackageInfo] = None
            if not item.url and item.is_valid_req:
                pypi_info = self.pypi_client.get_package_info(item.req_name)
                self._display_pypi_info(pypi_info, print_func)
            elif item.url:
                print_func(f"PyPI status: {Colors.c('Direct URL / Git dependency (skipped PyPI check)', Colors.DIM)}")

            # Check cached decision from earlier subprojects
            cached_decision = self.decisions.get(item.canonical_name)
            if cached_decision:
                print_func(
                    f"Cached choice from {Colors.c(cached_decision.source_project, Colors.CYAN)}: "
                    f"{Colors.c(cached_decision.specifier or '(keep original)', Colors.BOLD + Colors.GREEN)}"
                )

            # Auto-accept cached if flag set AND this is a dev dependency
            if self.auto_accept_cached and cached_decision and is_dev_dependency(item):
                new_spec, new_raw = format_new_requirement_string(item, cached_decision.raw_specifier_input)
                self.staged_changes[current_idx] = (new_spec, new_raw)
                print_func(Colors.c(f"-> Auto-applied cached version (dev dependency): {new_spec}", Colors.GREEN))
                current_idx += 1
                continue

            # Prompt user
            prompt_parts = []
            if cached_decision:
                prompt_parts.append(f"Enter to use cached '{cached_decision.specifier or 'keep'}'")
            else:
                prompt_parts.append("Enter/k to keep")
            if pypi_info and pypi_info.latest_eligible:
                prompt_parts.append(f"l for latest ({pypi_info.latest_eligible.version_str})")
            prompt_parts.append("<version_range> to set")
            prompt_parts.append("s=skip")
            if current_idx > 0:
                prompt_parts.append("p=prev")
            prompt_parts.append("h=help, q=quit")

            prompt_text = f"Action [{', '.join(prompt_parts)}]: "

            try:
                user_choice = input_func(prompt_text).strip()
            except (EOFError, KeyboardInterrupt):
                print_func("\nAborted by user.")
                return False

            cmd = user_choice.lower()

            if cmd in ("h", "help", "?"):
                self._print_help(print_func)
                continue

            if cmd in ("q", "quit", "exit"):
                confirm = input_func("Save staged changes made so far before exiting? [y/N/cancel]: ").strip().lower()
                if confirm == "y":
                    self.apply_staged_changes(print_func)
                    return True
                elif confirm == "cancel":
                    continue
                else:
                    print_func("Exiting without saving remaining changes.")
                    return False

            if cmd in ("p", "prev", "previous", "b", "back"):
                if current_idx > 0:
                    current_idx -= 1
                    print_func(Colors.c("<< Navigating to previous dependency", Colors.BLUE))
                else:
                    print_func(Colors.c("Already at the first dependency.", Colors.YELLOW))
                continue

            if cmd in ("s", "skip"):
                print_func(Colors.c("-> Skipped (unchanged)", Colors.DIM))
                current_idx += 1
                continue

            if cmd == "a" or cmd == "auto" or cmd == "all-cached":
                self.auto_accept_cached = True
                print_func(Colors.c("Enabled auto-accept for cached dev dependencies.", Colors.GREEN))
                if cached_decision and is_dev_dependency(item):
                    new_spec, new_raw = format_new_requirement_string(item, cached_decision.raw_specifier_input)
                    self.staged_changes[current_idx] = (new_spec, new_raw)
                    current_idx += 1
                    continue
                else:
                    # Not a dev dependency or no cached decision yet, continue prompt for this item
                    continue

            if cmd in ("d", "diff", "summary"):
                self.print_staged_summary(print_func)
                continue

            # Determine new specifier value
            if user_choice == "":
                if cached_decision:
                    raw_input_to_apply = cached_decision.raw_specifier_input
                else:
                    # Keep original
                    raw_input_to_apply = item.specifier
            elif cmd in ("k", "keep"):
                raw_input_to_apply = item.specifier
            elif cmd in ("l", "latest"):
                if pypi_info and pypi_info.latest_eligible:
                    raw_input_to_apply = f">={pypi_info.latest_eligible.version_str}"
                elif pypi_info and pypi_info.latest:
                    raw_input_to_apply = f">={pypi_info.latest.version_str}"
                else:
                    print_func(Colors.c("No PyPI version available to select as latest.", Colors.RED))
                    continue
            else:
                # Validate input format (enforcing >=X.X.X,<Y.Y.Y order and valid specifiers)
                valid, err_msg = validate_version_input(user_choice)
                if not valid:
                    print_func(Colors.c(f"Error: {err_msg}", Colors.RED))
                    continue
                raw_input_to_apply = user_choice

            new_spec, new_raw = format_new_requirement_string(item, raw_input_to_apply)

            # Check for cross-project mismatch / hint
            if (
                cached_decision
                and cached_decision.source_project != item.project_name
                and new_spec != cached_decision.specifier
            ):
                print_func(
                    Colors.c(
                        f"\n[HINT] Different version range set for '{item.req_name}'!\n"
                        f"  - In '{item.project_name}': {new_spec or '(unconstrained)'}\n"
                        f"  - Previously in '{cached_decision.source_project}': {cached_decision.specifier or '(unconstrained)'}",
                        Colors.YELLOW + Colors.BOLD,
                    )
                )
                try:
                    conf = input_func("Confirm different version for this subproject? [Y/n]: ").strip().lower()
                except (EOFError, KeyboardInterrupt):
                    return False
                if conf == "n":
                    continue

            # Cache the decision if not yet cached or if updating in the source project
            if item.canonical_name not in self.decisions or cached_decision.source_project == item.project_name:
                self.decisions[item.canonical_name] = DependencyDecision(
                    canonical_name=item.canonical_name,
                    package_name=item.req_name,
                    specifier=new_spec,
                    source_project=item.project_name,
                    raw_specifier_input=raw_input_to_apply,
                )

            # Stage the change
            if new_raw != item.raw_text:
                self.staged_changes[current_idx] = (new_spec, new_raw)
                print_func(Colors.c(f"-> Updated: {item.raw_text} => {new_raw}", Colors.GREEN))
            else:
                if current_idx in self.staged_changes:
                    del self.staged_changes[current_idx]
                print_func(Colors.c("-> Kept unchanged", Colors.DIM))

            current_idx += 1

        print_func("\n" + "=" * 70)
        print_func(Colors.c("Review and Save Changes", Colors.BOLD + Colors.CYAN))
        print_func("=" * 70)
        self.print_staged_summary(print_func)

        if not self.staged_changes:
            print_func(Colors.c("No changes to apply.", Colors.GREEN))
            return True

        try:
            save_choice = input_func("Apply these changes to pyproject.toml files? [Y/n]: ").strip().lower()
        except (EOFError, KeyboardInterrupt):
            print_func("\nAborted.")
            return False

        if save_choice != "n":
            self.apply_staged_changes(print_func)
            return True
        else:
            print_func("Aborted. No files were modified.")
            return False

    def _display_pypi_info(self, pypi_info: PyPIPackageInfo, print_func=print):
        if pypi_info.error:
            print_func(f"PyPI status: {Colors.c(pypi_info.error, Colors.YELLOW)}")
            return

        latest = pypi_info.latest
        latest_eligible = pypi_info.latest_eligible

        if not latest:
            print_func(f"PyPI status: {Colors.c('No release information available', Colors.YELLOW)}")
            return

        date_str = latest.upload_time.strftime("%Y-%m-%d")
        if latest.is_disallowed:
            warn_msg = f"Latest on PyPI: {Colors.c(latest.version_str, Colors.BOLD + Colors.RED)} ({date_str}, {latest.age_days}d ago) [⚠️ DISALLOWED: < {self.pypi_client.min_age_days} days old]"
            print_func(f"PyPI status: {warn_msg}")
            if latest_eligible:
                elig_date = latest_eligible.upload_time.strftime("%Y-%m-%d")
                print_func(
                    f"             Latest eligible (>= {self.pypi_client.min_age_days}d): "
                    f"{Colors.c(latest_eligible.version_str, Colors.BOLD + Colors.GREEN)} ({elig_date}, {latest_eligible.age_days}d ago)"
                )
            else:
                print_func(
                    f"             {Colors.c('No release >= 7 days old found on PyPI.', Colors.RED)}"
                )
        else:
            print_func(
                f"PyPI status: Latest: {Colors.c(latest.version_str, Colors.BOLD + Colors.GREEN)} ({date_str}, {latest.age_days}d ago)"
            )

    def _print_help(self, print_func=print):
        print_func(Colors.c("\nHelp & Commands:", Colors.BOLD))
        print_func("  <version_range>  : Enter a version range or specifier, e.g.:")
        print_func("                     '>=2.0.0,<3.0.0', '==1.2.3', '^1.2.3', '>=1.2.3'")
        print_func("  <Enter>          : Keep current version, or use cached value if previously set")
        print_func("  k, keep          : Explicitly keep current version unchanged")
        print_func("  l, latest        : Use latest eligible version from PyPI (>= 7 days old)")
        print_func("  s, skip          : Skip this dependency without changing")
        print_func("  p, prev, back    : Go back to previous dependency")
        print_func("  a, auto          : Auto-apply cached values for dev dependencies (e.g. pytest)")
        print_func("  d, diff          : Show summary of all staged changes so far")
        print_func("  h, help          : Show this help message")
        print_func("  q, quit          : Quit wizard (with option to save)\n")

    def print_staged_summary(self, print_func=print):
        if not self.staged_changes:
            print_func(Colors.c("No staged changes.", Colors.DIM))
            return

        print_func(Colors.c(f"Staged changes ({len(self.staged_changes)} dependencies):", Colors.BOLD))
        by_file: Dict[Path, List[Tuple[DependencyItem, str]]] = {}
        for idx, (_, new_raw) in self.staged_changes.items():
            item = self.items[idx]
            by_file.setdefault(item.project_path, []).append((item, new_raw))

        for path, changes in by_file.items():
            rel = path.relative_to(self.root_dir).as_posix()
            print_func(f"\n  File: {Colors.c(rel, Colors.BOLD + Colors.CYAN)}")
            for item, new_raw in changes:
                print_func(
                    f"    [{item.section_name}] {Colors.c(item.raw_text, Colors.RED)} -> {Colors.c(new_raw, Colors.GREEN)}"
                )
        print_func("")

    def apply_staged_changes(self, print_func=print):
        if not self.staged_changes:
            print_func(Colors.c("No changes to apply.", Colors.YELLOW))
            return

        by_file: Dict[Path, List[Tuple[DependencyItem, str]]] = {}
        for idx, (_, new_raw) in self.staged_changes.items():
            item = self.items[idx]
            by_file.setdefault(item.project_path, []).append((item, new_raw))

        for path, changes in by_file.items():
            with open(path, "r", encoding="utf-8") as f:
                content = f.read()

            if tomlkit is not None:
                doc = tomlkit.parse(content)
                for item, new_raw in changes:
                    target = doc
                    for key in item.section_key_path:
                        target = target[key]
                    target[item.index] = new_raw
                new_content = tomlkit.dumps(doc)
            else:
                new_content = content
                for item, new_raw in changes:
                    pattern = re.compile(rf'([\"\']){re.escape(item.raw_text)}([\"\'])')
                    new_content = pattern.sub(rf'\g<1>{new_raw}\g<2>', new_content, count=1)

            with open(path, "w", encoding="utf-8") as f:
                f.write(new_content)

            rel = path.relative_to(self.root_dir).as_posix()
            print_func(Colors.c(f"✓ Updated {rel} ({len(changes)} dependencies modified)", Colors.GREEN))

        print_func(Colors.c("\nAll pyproject.toml files successfully updated!", Colors.BOLD + Colors.GREEN))


def main():
    parser = argparse.ArgumentParser(
        description="Biocentral Interactive Dependency Version Manager",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "--project",
        "-p",
        help="Target a specific subproject by name or path (e.g. 'biocentral_server')",
        default=None,
    )
    parser.add_argument(
        "--root",
        "-r",
        help="Path to repository root directory (default: workspace root)",
        default=None,
    )
    parser.add_argument(
        "--auto-accept-cached",
        "-a",
        action="store_true",
        default=True,
        help="Automatically apply cached package decisions for dev dependencies without re-prompting",
    )
    args = parser.parse_args()

    if args.root:
        root_dir = Path(args.root).resolve()
    else:
        # Default: 2 levels up from _global/bin
        root_dir = Path(__file__).resolve().parent.parent.parent

    session = DependencyManagerSession(root_dir=root_dir, auto_accept_cached=args.auto_accept_cached)
    session.load_all_items(target_project=args.project)
    success = session.run_interactive()
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
