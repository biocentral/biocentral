---
"biocentral-server": major
---

Migrate from Poetry to UV package manager

**Breaking Changes:**

- Package manager changed from Poetry to UV
- Use `uv sync --group dev` instead of `poetry install`
- Use `uv run` instead of `poetry run`
- Virtual environment now managed by UV in `.venv/`

**Changes:**

- Convert pyproject.toml to PEP 621 standard format
- Add UV lock file (`uv.lock`) for reproducible builds
- Fix platform-specific dependencies (psycopg[binary], onnxruntime)
- All 159 packages verified and working

**Benefits:**

- Faster dependency resolution and installation
- Better lock file handling and reproducibility
- Simplified development workflow
- Future-proof package management
