# Getting started with biocentral_server

This guide describes how to install and run the biocentral_server.

## Installation

### Prerequisites

biocentral_server has been developed and tested throughout on Ubuntu 24.04.
It should also work on Windows 11 and macOS, but this has not been tested yet in-depth.

Make sure that you have [git](https://git-scm.com/install/) and
[docker](https://docs.docker.com/engine/install/ubuntu/) installed.

### Steps

Clone the repository and navigate into it:

```shell
git clone https://github.com/biocentral/biocentral_server.git
cd biocentral_server
```

Copy the environment file and check that it matches your requirements:

```shell
```shell
cp .env.example .env
```

Run the entire setup, including embedding database, prediction models and the server via docker compose:

```shell
docker compose up -d
```

## Update

```shell
# Stop the server
docker compose down
# Pull repository changes
git pull
# Pull docker image changes
docker compose pull
# Start the server again
docker compose up -d
```
