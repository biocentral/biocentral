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
	CP := powershell -Command "Copy-Item"
    RM := powershell -Command "Remove-Item" -r -Force
    ZIP := powershell -Command "Compress-Archive"
else
    DETECTED_OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
    ARCH := $(shell uname -m | tr '[:upper:]' '[:lower:]')
    VERSION := $(shell grep '^version = ' $(PYPROJECT_FILE) | sed 's/^version = "\(.*\)"$$/\1/' | tr . -)
	PYTHON_BIN := $(shell which python3)
	CP := cp
    RM := rm -rf
    ZIP := zip -r
endif

# Set ZIP_NAME based on OS, architecture, and version
ZIP_NAME := biocentral_server_$(VERSION)_$(DETECTED_OS)_$(ARCH).zip

# Default target
all: clean build bundle

# Clean build artifacts
clean:
	$(RM) build
	$(RM) dist

# Build the executable
build:
	$(PYINSTALLER) $(SPEC_FILE)

# Copy assets and create zip
bundle:
	$(CP) -r $(ASSET_DIR) $(DIST_DIR)
	$(CP) $(LICENSE_FILE) $(DIST_DIR)
ifeq ($(OS),Windows_NT)
	cd $(DIST_DIR) && $(ZIP) -Path * -DestinationPath ../$(ZIP_NAME)
else
	cd $(DIST_DIR) && $(ZIP) ../$(ZIP_NAME) .
endif

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
