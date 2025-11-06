# biocentral_server

Heavy compute functionality for biocentral. Provided via a dockerized FastAPI server.

## Features and modules

These are the currently provided modules:

| Module        |                    Features                     | External Dependencies |
|---------------|:-----------------------------------------------:|:---------------------:|
| embeddings    |             Embed protein sequences             |     [biotrainer]      |
| ppi           |     Work with protein-protein interactions      |     [hvi_toolkit]     |
| predict       |   Create predictions from pre-trained models    |   [TMbed], [VespaG]   |
| custom_models | Train and evaluate models trained on embeddings |     [biotrainer]      |
| proteins      |             Work with protein data              |       [taxoniq]       |
| plm_eval      | Automatically evaluate protein language models  |  [biotrainer], [PBC]  |

[biotrainer]: https://github.com/sacdallago/biotrainer

[hvi_toolkit]: https://github.com/SebieF/hvi_toolkit

[taxoniq]: https://github.com/taxoniq/taxoniq

[PBC]: https://github.com/Rostlab/pbc

[TMbed]: https://github.com/BernhoferM/TMbed

[VespaG]: https://github.com/JSchlensok/VespaG/


## Installing and running

See the docs on [how to get started](/docs/getting_started.md) with biocentral_server.

For development, see the [development guide](/docs/Contributing/development_setup.md).

## Citation

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
