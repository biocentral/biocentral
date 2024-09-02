# Makefile for Biocentral Server

# Variables
PYTHON = poetry run python
PYINSTALLER = poetry run pyinstaller
SRC_DIR = .
DIST_DIR = dist/biocentral_server
SPEC_FILE = biocentral_server.spec
MAIN_SCRIPT = biocentral_server.py
ASSET_DIR = assets
LICENSE_FILE = LICENSE
PYPROJECT_FILE = pyproject.toml

# Determine OS and architecture
ifeq ($(OS),Windows_NT)
    DETECTED_OS := windows
    ARCH := 10 # TODO Use ver command
else
    DETECTED_OS := $(shell uname -s | tr '[:upper:]' '[:lower:]')
    ARCH := $(shell uname -m | tr '[:upper:]' '[:lower:]')
endif


# Read version from pyproject.toml
VERSION := $(shell grep '^version = ' $(PYPROJECT_FILE) | sed 's/^version = "\(.*\)"$$/\1/' | tr . -)

# Set ZIP_NAME based on OS, architecture, and version
ZIP_NAME := biocentral_server_$(VERSION)_$(DETECTED_OS)_$(ARCH).zip

# Default target
all: clean build bundle

# Clean build artifacts
clean:
	rm -rf build dist

# Build the executable
build:
	$(PYINSTALLER) --add-binary '/usr/bin/python3.11:.' $(MAIN_SCRIPT)

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

.PHONY: all clean build bundle spec run print-info
