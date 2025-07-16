# Getting started with biocentral_server

## Installing and running

Make sure that you have `Python 3.11` and [poetry](https://python-poetry.org/docs/#installation) installed.

```shell
# [Ubuntu 24.04]
# Install additional dependencies
sudo apt-get install python3-tk
sudo apt-get install libcairo2-dev libxt-dev libgirepository1.0-dev
poetry install --extras linux

# [Windows 10/11]
poetry install
# Install torch with hardware settings for your system (see here: https://pytorch.org/get-started/locally/)
pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118

# Run with visual control panel
poetry run run-biocentral_server.py
```

Now you should see the following control panel appear:

![Biocentral Server Control Panel](images/control_panel.png "Biocentral Server Control Panel")

You can start and stop the server there, view statistics and available devices.
