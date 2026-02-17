# biocentral_server

Compute functionality for biocentral. Provided via a dockerized FastAPI server.

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

Please cite [our paper](https://doi.org/10.1016/j.jmb.2026.169673) if you are using *biocentral* in your work:

```text
@Article{Franz2026,
  author    = {Franz, Sebastian and Olenyi, Tobias and Schloetermann, Paula and Smaoui, Amine and Jimenez-Soto, Luisa F. and Rost, Burkhard},
  journal   = {Journal of Molecular Biology},
  title     = {biocentral: embedding-based protein predictions},
  year      = {2026},
  issn      = {0022-2836},
  month     = jan,
  pages     = {169673},
  doi       = {10.1016/j.jmb.2026.169673},
  groups    = {[JMB] biocentral: embedding-based protein predictions, swc_bo_engineering},
  publisher = {Elsevier BV},
}
```
