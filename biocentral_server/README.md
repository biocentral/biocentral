# Biocentral server

Flask-based python server using REST API that provides functionality for the biocentral frontend.

## Features and modules

These are the currently provided modules:

| Module            |                    Features                     | Dependencies  | 
|-------------------|:-----------------------------------------------:|:-------------:|
| protein_analysis  |                       wip                       |               | 
| embeddings        |             Embed protein sequences             | [biotrainer]  | 
| ppi               |     Work with protein-protein interactions      | [hvi_toolkit] | 
| prediction_models | Train and evaluate models trained on embeddings | [biotrainer]  |
| proteins          |             Work with protein data              | [hvi_toolkit] |

[biotrainer]: https://github.com/sacdallago/biotrainer
[hvi_toolkit]: https://github.com/SebieF/hvi_toolkit

## Supported platforms

`Biocentral` and `biocentral_server` are designed to provide all common desktop operating systems 
(Windows, Linux, macOS). 
The following table gives an overview about the current test and packaging status:

| OS           | Tested  | Packaging |
|--------------|:-------:|:---------:|
| Ubuntu 24.04 |    ✅    |   .zip    |
| Ubuntu 22.04 |    ✅    |   .zip    |
| Windows 10   | planned |    tbd    |
| Windows 11   | planned |    tbd    |
| macOS        | planned |    tbd    |

## Installing and running

Make sure that you have `Python 3.11` and [poetry](https://python-poetry.org/docs/#installation) installed.

```shell
# [Ubuntu 24.04] 
# Install additional dependencies 
sudo apt-get install python3-tk
sudo apt-get install libcairo2-dev libxt-dev libgirepository1.0-dev
# Uncomment pygobject = "^3.48.2" in pyproject.toml
poetry update

# [Windows 10/11]
poetry install
# Install torch with hardware settings for your system (see here: https://pytorch.org/get-started/locally/)
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Run with visual control panel
poetry run run-biocentral_server.py

# Run headless
poetry run run-biocentral_server.py --headless
```

## Building

Building and bundling is done using [pyinstaller](https://pyinstaller.org/en/stable/) and `make`. 

On Windows, you can use `winget` to install `make`:
```shell
winget install ezwinports.make
```

Check that all build variables are correct:
```shell
make print-info
```

Then call build:
```shell
make build
```

To create a `zip` file with all required files for distribution:
```shell
make bundle
```

*Note that this file only works on the operating system version you ran `make build` on!*
