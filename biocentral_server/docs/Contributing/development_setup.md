# Setting biocentral_server up for local development

This guide describes how to set up biocentral_server for local development, enabling direct python debugging.

## Installation

### Prerequisites

biocentral_server has been developed and tested throughout on Ubuntu 24.04.
It should also work on Windows 11 and macOS, but this has not been tested yet in-depth.

Make sure that you have [git](https://git-scm.com/install/), [uv](https://docs.astral.sh/uv/getting-started/installation/) and
[docker](https://docs.docker.com/engine/install/ubuntu/) installed.

### Steps

Clone the repository and navigate into it:

```shell
git clone https://github.com/biocentral/biocentral_server.git
cd biocentral_server
```

Create a new python environment and install the requirements:
```shell
uv venv
source .venv/bin/activate
uv sync --group dev
```

Copy the local environment file and check that it matches your requirements:

```shell
```shell
cp .env.local .env
```

Run the additional containers (database, redis, triton etc.) via docker compose:

```shell
docker compose -f docker-compose.dev.yml up -d
```

Run the server locally with workers:
```shell
uv run run-local.py
```
