import os
import sys
import shutil
import subprocess
import getpass
import argparse
import requests
import yaml
import tomllib
from typing import List, Dict, Optional
from pathlib import Path

# --- Configuration ---
PROJECT_ROOT = Path(__file__).parent.parent.parent.resolve()

PACKAGES = [
    {
        "name": "biocentral_api",
        "type": "pypi",
        "path": PROJECT_ROOT / "biocentral_api" / "python",
        "changelog": PROJECT_ROOT / "Changelog.md",
    },
    {
        "name": "biocentral_api",
        "type": "pub.dev",
        "path": PROJECT_ROOT / "biocentral_api" / "dart",
        "changelog": PROJECT_ROOT / "biocentral_api" / "dart" / "CHANGELOG.md",
    },
    {
        "name": "biocentral_vis",
        "type": "pypi",
        "path": PROJECT_ROOT / "biocentral_vis" / "python",
        "changelog": PROJECT_ROOT / "Changelog.md",
    },
    {
        "name": "biocentral",
        "type": "pypi",
        "path": PROJECT_ROOT / "biocentral_python",
        "changelog": PROJECT_ROOT / "Changelog.md",
    }
]

# Adjusting changelog paths based on exploration
# biocentral_api/dart/CHANGELOG.md exists
# biocentral_vis/flutter/CHANGELOG.md exists
# biocentral_python/README.md - need to check if there is a better one

def run_command(command: str, cwd: Path, env: Optional[Dict[str, str]] = None, capture_output=False):
    print(f"\n> Running: {command} (in {cwd})")
    
    # Clean up environment to avoid uv warnings about VIRTUAL_ENV mismatch
    actual_env = os.environ.copy()
    if "VIRTUAL_ENV" in actual_env:
        del actual_env["VIRTUAL_ENV"]
    if env:
        actual_env.update(env)
        
    result = subprocess.run(command, shell=True, cwd=str(cwd), env=actual_env, text=True, capture_output=capture_output)
    if result.returncode != 0:
        if capture_output:
            print(result.stdout)
            print(result.stderr)
        raise Exception(f"Command failed with exit code {result.returncode}: {command}")
    return result

def get_version_from_file(pkg: Dict) -> str:
    path = pkg["path"]
    if pkg["type"] == "pypi":
        toml_path = path / "pyproject.toml"
        with open(toml_path, "rb") as f:
            data = tomllib.load(f)
            return data["project"]["version"]
    elif pkg["type"] == "pub.dev":
        yaml_path = path / "pubspec.yaml"
        with open(yaml_path, "r") as f:
            data = yaml.safe_load(f)
            return data["version"]
    return ""

def check_version_in_changelog(pkg: Dict, version: str) -> bool:
    changelog_path = pkg.get("changelog")
    if not changelog_path or not changelog_path.exists():
        print(f"Warning: Changelog not found for {pkg['name']} at {changelog_path}")
        return False
    
    with open(changelog_path, "r") as f:
        content = f.read()
        return version in content

def is_version_on_pypi(package_name: str, version: str) -> bool:
    url = f"https://pypi.org/pypi/{package_name}/{version}/json"
    response = requests.get(url)
    return response.status_code == 200

def is_version_on_pub_dev(package_name: str, version: str) -> bool:
    url = f"https://pub.dev/api/packages/{package_name}/versions/{version}"
    response = requests.get(url)
    return response.status_code == 200

def check_already_deployed(pkg: Dict, version: str) -> bool:
    if pkg["type"] == "pypi":
        return is_version_on_pypi(pkg["name"], version)
    elif pkg["type"] == "pub.dev":
        return is_version_on_pub_dev(pkg["name"], version)
    return False

def build_python(pkg: Dict) -> bool:
    cwd = pkg["path"]
    
    # Upgrade to latest dependencies
    run_command("uv sync --upgrade", cwd)
    
    # Install build tools - make sure we use the project environment
    run_command("uv pip install build twine", cwd)
    
    # Clean up any old builds first
    dist_dir = cwd / "dist"
    build_dir = cwd / "build"
    if dist_dir.exists(): shutil.rmtree(dist_dir)
    if build_dir.exists(): shutil.rmtree(build_dir)
    for egg_info in cwd.glob("*.egg-info"):
        if egg_info.is_dir():
            shutil.rmtree(egg_info)
        
    # Build both wheel and source distribution
    run_command("uv run python -m build", cwd)
    
    # Check the build
    run_command("uv run twine check dist/*", cwd)
    return True

def upload_python(pkg: Dict, pypi_token: str):
    cwd = pkg["path"]
    # Upload to PyPI
    env = os.environ.copy()
    env["TWINE_USERNAME"] = "__token__"
    env["TWINE_PASSWORD"] = pypi_token
    
    run_command("uv run twine upload dist/*", cwd, env=env)

def build_dart(pkg: Dict) -> bool:
    cwd = pkg["path"]
    
    # Sync environment (dart pub get)
    run_command("dart pub get", cwd)
    
    # Run dry-run
    try:
        run_command("dart pub publish --dry-run", cwd)
        return True
    except Exception as e:
        print(f"Dart package build failed: {e}")
        return False

def publish_dart(pkg: Dict):
    cwd = pkg["path"]
    # This will be interactive if authorization is needed
    subprocess.run("dart pub publish", shell=True, cwd=str(cwd))

def main():
    target_version = "2.0.0" # Specified version number
    
    parser = argparse.ArgumentParser(description="Biocentral Build and Release Script")
    parser.add_argument("--dry-run", action="store_true", help="Execute in dry-run mode (default)")
    parser.add_argument("--release", action="store_true", help="Execute in release mode")
    
    args = parser.parse_args()
    
    # Fallback to dry-run if neither or both are specified
    dry_run = True
    if args.release and not args.dry_run:
        dry_run = False
        
    mode_str = "DRY RUN" if dry_run else "RELEASE"
    print(f"=== Biocentral Release Script - Target Version: {target_version} ({mode_str} mode) ===")

    pypi_token = None
    if not dry_run:
        pypi_token = getpass.getpass("Enter PyPI API Token: ")

    # Release loop
    summary = []
    for pkg in PACKAGES:
        package_status = []
        print(f"\n--- Processing {pkg['name']} ({pkg['type']}) ---")

        # 1. Check version and changelog
        current_ver = get_version_from_file(pkg)
        pkg_version_ok = current_ver == target_version
        pkg_changelog_ok = check_version_in_changelog(pkg, target_version)
        
        if pkg_version_ok:
            package_status.append(f"OK: Version matches {target_version}")
        else:
            package_status.append(f"FAILED: Version is {current_ver}, expected {target_version}")
            
        if pkg_changelog_ok:
            package_status.append("OK: Changelog verified")
        else:
            package_status.append(f"FAILED: Changelog does not mention {target_version}")

        # 2. Check if already deployed
        already_deployed = False
        try:
            already_deployed = check_already_deployed(pkg, target_version)
            if already_deployed:
                package_status.append("ALREADY DEPLOYED: Version is already on registry")
        except Exception as e:
            package_status.append(f"WARNING: Could not check deployment status: {e}")

        if not pkg_version_ok or not pkg_changelog_ok:
            print(f"\nVerification failed for {pkg['name']}.")
            choice = input("Continue anyway? (y/n): ")
            if choice.lower() != 'y':
                summary.append(f"{pkg['name']} ({pkg['type']}): Verification Failed - Skipped")
                continue

        if already_deployed:
            print(f"\nSkipping {pkg['name']} as it is already deployed.")
            summary.append(f"{pkg['name']} ({pkg['type']}): Already deployed")
            input("Press Enter to continue to next package...")
            continue

        # 3. Build and check
        try:
            build_success = False
            if pkg["type"] == "pypi":
                build_success = build_python(pkg)
            elif pkg["type"] == "pub.dev":
                build_success = build_dart(pkg)

            build_status_msg = "OK: Build and Check SUCCESS" if build_success else "ERROR: Build and Check FAILED"
            package_status.append(build_status_msg)

            # Print summary for this package
            print(f"\n--- Summary for {pkg['name']} ({pkg['type']}) ---")
            print(f"  Version: {target_version}")
            for status in package_status:
                print(f"  {status}")
            
            if dry_run:
                # 5. If dry_run: User input: If yes, continue to next package
                choice = input("\nContinue to next package? (y/n): ")
                if choice.lower() == 'y':
                    summary.append(f"{pkg['name']} ({pkg['type']}): Dry Run Success")
                    continue
                else:
                    summary.append(f"{pkg['name']} ({pkg['type']}): Aborted by user")
                    break
            else:
                # 4. If not dry_run: User input: If yes, release, continue to next package
                print("\nReady for release.")
                choice = input(f"Release {pkg['name']} now? (y/n): ")
                if choice.lower() == 'y':
                    if pkg["type"] == "pypi":
                        upload_python(pkg, pypi_token)
                    elif pkg["type"] == "pub.dev":
                        publish_dart(pkg)
                    summary.append(f"{pkg['name']} ({pkg['type']}): Success")
                else:
                    print("Release skipped by user.")
                    summary.append(f"{pkg['name']} ({pkg['type']}): Release Skipped")
                    choice = input("Continue to next package? (y/n): ")
                    if choice.lower() != 'y':
                        break
        except Exception as e:
            print(f"Error processing {pkg['name']}: {e}")
            summary.append(f"{pkg['name']} ({pkg['type']}): FAILED - {e}")
            choice = input("Continue with next package? (y/n): ")
            if choice.lower() != 'y':
                break

    print("\n=== Final Release Summary ===")
    for item in summary:
        print(item)

if __name__ == "__main__":
    main()
