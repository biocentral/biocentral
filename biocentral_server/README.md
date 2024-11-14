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
| proteins          |             Work with protein data              |   [taxoniq]   |

[biotrainer]: https://github.com/sacdallago/biotrainer

[hvi_toolkit]: https://github.com/SebieF/hvi_toolkit

[taxoniq]: https://github.com/taxoniq/taxoniq

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
<summary>Advanced MongoDB setup</summary>

For advanced users or production deployments we recommend using a [MongoDB](https://www.mongodb.com) instance. 
Here's a step-by-step guide how to configure it for *biocentral_server*:
```shell
# 1. Install MongoDB, e.g. for Ubuntu see: https://www.mongodb.com/docs/manual/tutorial/install-mongodb-on-ubuntu/
# 2. Set up an admin user and enable authentication
# Go to mongo shell
mongosh

# Create Admin User
use admin;
db.createUser(
  {
    user: 'admin',
    pwd: 'password',  # Change this!
    roles: [ { role: 'root', db: 'admin' } ]
  }
);
exit;

# Change config to enable authentication
sudo nano /etc/mongod.conf 

# Change security to the following lines:
security:
  authorization: enabled

# Restart the mongodb process
sudo systemctl restart mongod

# 3. Create the embeddings database
# Log into mongo shell with the admin user you created
mongosh -u admin -p

# Create a user for the application
use embeddings_db;
db.createUser(
  {
    user: "embeddingsUser",
    pwd: "embeddingsPassword",  # Change this!
    roles: [ { role: "readWrite", db: "embeddings_db" } ]
  }
);

# Create the database collection
db.createCollection("embeddings");
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