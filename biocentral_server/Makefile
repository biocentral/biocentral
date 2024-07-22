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
ZIP_NAME = biocentral_server.zip

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

.PHONY: all clean build bundle spec run
