# Biocentral server

Flask-based python server using REST API that provides functionality for the biocentral frontend.

## Features and modules

These are the currently provided modules:

| Module            |                    Features                     | External Dependencies |
|-------------------|:-----------------------------------------------:|:---------------------:|
| protein_analysis  |                       wip                       |                       |
| embeddings        |             Embed protein sequences             |     [biotrainer]      |
| ppi               |     Work with protein-protein interactions      |     [hvi_toolkit]     |
| predict           |   Create predictions from pre-trained models    |   [TMbed], [VespaG]   |
| prediction_models | Train and evaluate models trained on embeddings |     [biotrainer]      |
| proteins          |             Work with protein data              |       [taxoniq]       |
| plm_eval          | Automatically evaluate protein language models  |  [autoeval], [FLIP]   |

[biotrainer]: https://github.com/sacdallago/biotrainer

[hvi_toolkit]: https://github.com/SebieF/hvi_toolkit

[taxoniq]: https://github.com/taxoniq/taxoniq

[autoeval]: https://github.com/J-SNACKKB/autoeval

[FLIP]: https://github.com/J-SNACKKB/FLIP

[TMbed]: https://github.com/BernhoferM/TMbed

[VespaG]: https://github.com/JSchlensok/VespaG/


## Installing and running

Make sure that you have `Python 3.12`, `docker` and [UV](https://docs.astral.sh/uv/getting-started/installation/) installed.

### Production Setup

```shell
# Copy environment file and check that it matches your setup
cp .env.example .env

# Run via docker compose
docker compose up -d

# Update
docker compose down
git pull
docker compose pull
docker compose up -d
```

### Local Setup

```shell
# Install dependencies with UV
uv sync --group dev

# Use environment variables for local setup
cp .env.local .env

# Run additional dependencies via docker compose
docker compose -f docker-compose.dev.yml up -d

# Run the server
uv run python run-biocentral_server.py

# Or run with workers for development
uv run python run-local.py
```

### Package Manager Migration

This project migrated from Poetry to UV for better performance and reliability:
- Use `uv sync --group dev` instead of `poetry install`
- Use `uv run` instead of `poetry run`
- Use `uv add package` to add dependencies

For full migration details, see the changeset documentation.

# Citation

Please cite the [biocentral main repository](https://github.com/biocentral/biocentral) if you are using
biocentral_server in your scientific publication:

```text
@Online{biocentral,
  accessed = {2024-09-10},
  author   = {Biocentral contributors},
  title    = {Biocentral - An open source bioinformatics application},
  url      = {https://github.com/biocentral/biocentral},
}
```
