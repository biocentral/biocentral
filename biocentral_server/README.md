# Biocentral server

Flask-based python server using REST API that provides functionality for the biocentral frontend.

## Features and modules

These are the currently provided modules:

| Module            |                    Features                     |    Dependencies    | 
|-------------------|:-----------------------------------------------:|:------------------:|
| protein_analysis  |                       wip                       |                    | 
| embeddings        |             Embed protein sequences             |    [biotrainer]    | 
| ppi               |     Work with protein-protein interactions      |   [hvi_toolkit]    | 
| prediction_models | Train and evaluate models trained on embeddings |    [biotrainer]    |
| proteins          |             Work with protein data              |     [taxoniq]      |
| plm_eval          | Automatically evaluate protein language models  | [autoeval], [FLIP] |

[biotrainer]: https://github.com/sacdallago/biotrainer

[hvi_toolkit]: https://github.com/SebieF/hvi_toolkit

[taxoniq]: https://github.com/taxoniq/taxoniq

[autoeval]: https://github.com/J-SNACKKB/autoeval

[FLIP]: https://github.com/J-SNACKKB/FLIP

## Supported platforms

`Biocentral` and `biocentral_server` are designed to provide all common desktop operating systems
(Windows, Linux, macOS).
The following table gives an overview about the current test and packaging status:

| OS           | Tested  | Packaging |
|--------------|:-------:|:---------:|
| Ubuntu 24.04 |    ✅    |   .zip    |
| Ubuntu 22.04 |    ✅    |   .zip    |
| Windows 10   |    ✅    |   .zip    |
| Windows 11   | planned |    tbd    |
| macOS        | planned |    tbd    |

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

# Run headless
poetry run run-biocentral_server.py --headless
```

### Additional setup

Embeddings that are computed via the server are stored in a NoSQL database. For local deployments, 
[TinyDB](https://github.com/msiemens/tinydb) is used by default and should be performant for most use cases. 
If you want to use TinyDB, you do not have to perform any additional installation steps - 
all embeddings are stored in `storage/embeddings.json`. 

<details>
<summary>Advanced PostgreSQL setup</summary>

For advanced users or production deployments we recommend using a [PostgreSQL](https://www.postgresql.org/) instance. 
Here's a step-by-step guide how to configure it for *biocentral_server*:
```shell
# 1. Install PostgreSQL, e.g. for Ubuntu see: https://www.postgresql.org/download/linux/ubuntu/
# 2. Configure PostgreSQL
# Switch to postgres user
sudo -i -u postgres

# Create a new database
createdb embeddings_db

# Access PostgreSQL prompt
psql

# Create a new user and set password
CREATE USER embeddingsuser WITH PASSWORD 'embeddingspwd';

# Grant privileges to the user on the database
GRANT ALL PRIVILEGES ON DATABASE embeddings_db TO embeddingsuser;

# Connect to the embeddings database
\c embeddings_db

# Grant schema privileges to the user
GRANT ALL ON SCHEMA public TO embeddingsuser;

# Exit PostgreSQL prompt
\q

# Exit postgres user shell
exit

# Restart PostgreSQL
sudo systemctl restart postgresql
```
</details>

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