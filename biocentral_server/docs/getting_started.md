# Getting started with biocentral_server

This guide describes how to install and run the biocentral_server.

## Installation

### Prerequisites

biocentral_server has been developed and tested throughout on Ubuntu 24.04.
It should also work on Windows 11 and macOS, but this has not been tested yet in-depth.

Your system must also have a (nvidia) GPU (recommended: at least 16GB of RAM). Additionally,
we recommend at least 32GB of RAM and 100GB of free disk space (for the docker container, models and embedding
database).

Make sure that you have [git](https://git-scm.com/install/),
[docker](https://docs.docker.com/engine/install/ubuntu/) and the
[nvidia-container-toolkit](https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/latest/install-guide.html)
installed.

### Steps

Clone the repository (anywhere on your system) and navigate into it:

```shell
git clone https://github.com/biocentral/biocentral_server.git
cd biocentral_server
```

The biocentral_server is configurable via an environment file (`.env`).
So, copy the example environment file and check that it matches your requirements:

```shell
cp .env.example .env
```

For all directories in the .env file, make sure that they exist on your system. If you use the default settings, you can
run the following command to ensure that:

```shell
mkdir -p ./storage/embeddings ./storage/files ./storage/server_temp_files ./storage/monitoring ~/.cache/huggingface ~/.cache/biotrainer/autoeval
```

*Note: This assumes that you do not run docker as root.
If you do, you need to replace the `~` with `/root` in the commands above, or choose a different directory for these
directories.*


Now run the entire setup, including the embedding database, prediction models and the server via docker compose:

```shell
docker compose up -d
```

## Update the server

To update the server, you can run the following commands:

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
