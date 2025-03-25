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

### Installation



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