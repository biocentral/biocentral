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

````shell
```shell
cp .env.local .env
````

Run the additional containers (database, redis, triton etc.) via docker compose
(automatically uses the `docker-compose.override.yml` file with appropriate overrides for local development):

```shell
docker compose up -d
```

Run the server locally with workers:

```shell
uv run run-local.py
```

## Local macOS engineering checks

Initialize the pinned submodule (`git submodule update --init biotrainer`) before
installing the server environment. The server and its biotrainer dependency must
come from the same checkout: an older embedding-service interface may reject the
server's `seed` argument. Keep both biotrainer and biotrainer-core aligned with
the pin when reusing an existing environment.

With local Redis/PostgreSQL configured as in `.env.local`, start the API in one
terminal. Disabling Triton lets local embedders run without an inference server:

```shell
USE_TRITON=false ENV_FILE=.env.local uv run run-local.py --host 127.0.0.1 --port 9540 --workers 0
```

On macOS, use a non-forking worker in another terminal. Forking a process after
PyTorch/Metal initialization can crash with an Objective-C initialization error.
This local setup leaves production worker behavior unchanged:

```shell
USE_TRITON=false uv run python -c '
from dotenv import load_dotenv
load_dotenv(".env.local")
from redis import Redis
from rq import SimpleWorker
SimpleWorker(["high", "default", "low"], connection=Redis(host="127.0.0.1", port=6379)).work()
'
```

Select localhost in the application's server configuration. One-hot encoding and
the random baseline provide a small diagnostic round without downloading a
language model. At least one numeric measurement is required by the iteration
API; a measured mutant can substitute for a wildtype measurement. Did-not-express
records are retained but cannot supply a numeric training target.

Engineering responses must identify variants by parent-relative substitutions
(e.g. `A12V`), with a prediction for every suggested ID. The frontend rejects
unresolvable responses before applying a round. It cannot reconstruct a sequence
from an opaque identifier such as `mutation_0`.
