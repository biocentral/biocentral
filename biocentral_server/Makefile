# Makefile for Biocentral Server

# Variables
PYTHON = poetry run python
PYINSTALLER = poetry run pyinstaller
SRC_DIR = .
DIST_DIR = dist/biocentral_server
SPEC_FILE = biocentral_server.spec
MAIN_SCRIPT = run-biocentral_server.py
ASSET_DIR = assets
LICENSE_FILE = LICENSE
PYPROJECT_FILE = pyproject.toml

# Determine OS and architecture
ifeq ($(OS),Windows_NT)
    DETECTED_OS := windows
    ARCH := $(shell powershell -Command "$$osInfo = Get-CimInstance Win32_OperatingSystem; $$osInfo.Version.Split('.')[0]")
    # Read version from pyproject.toml
    VERSION := $(shell powershell -Command "$$version = Select-String -Path $(PYPROJECT_FILE) -Pattern '^version = ' | ForEach-Object { $$_.Line -replace '^version = \"(.*)\"$$', '$$1' }; $$version -replace '\.','-'")
	PYTHON_BIN := $(shell where python)
else
    DETECTED_OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
    ARCH := $(shell uname -m | tr '[:upper:]' '[:lower:]')
    VERSION := $(shell grep '^version = ' $(PYPROJECT_FILE) | sed 's/^version = "\(.*\)"$$/\1/' | tr . -)
	PYTHON_BIN := $(shell which python3)
endif

# Set ZIP_NAME based on OS, architecture, and version
ZIP_NAME := biocentral_server_$(VERSION)_$(DETECTED_OS)_$(ARCH).zip

# Default target
all: clean build bundle

# Clean build artifacts
clean:
	rm -rf build dist

# Build the executable
build:
ifeq ($(DETECTED_OS),windows)
	$(PYINSTALLER) --add-binary "$(PYTHON_BIN);." $(MAIN_SCRIPT)
else
	$(PYINSTALLER) --add-binary "$(PYTHON_BIN):." $(MAIN_SCRIPT)
endif

# Copy assets and create zip
bundle:
	cp -r $(ASSET_DIR) $(DIST_DIR)
	cp $(LICENSE_FILE) $(DIST_DIR)
	cd $(DIST_DIR) && zip -r ../$(ZIP_NAME) .

# Create spec file (run once)
spec:
	$(PYINSTALLER) --name biocentral_server $(MAIN_SCRIPT)

# Run the application (for testing)
run:
	$(PYTHON) $(MAIN_SCRIPT)

# Print the detected OS, architecture, and version (for debugging)
print-info:
	@echo "Detected OS: $(DETECTED_OS)"
	@echo "Architecture: $(ARCH)"
	@echo "Version: $(VERSION)"
	@echo "ZIP Name: $(ZIP_NAME)"
	@echo "Python Binary: $(PYTHON_BIN)"

.PHONY: all clean build bundle spec run print-info
