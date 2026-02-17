# biocentral_api - Python Client

Python API package for biocentral.

## Installation

```shell
pip install biocentral-api
```

## Basic Usage

**Embedding protein sequences**:
```python
from biocentral_api import BiocentralAPI, CommonEmbedder

biocentral_api = BiocentralAPI()

# ProtT5
embedder_name = CommonEmbedder.ProtT5
reduce = True
sequence_data = {"Seq1": "MMALSLALM"}
result = biocentral_api.embed(embedder_name=embedder_name, reduce=reduce, sequence_data=sequence_data,
                            use_half_precision=False).run()
print(result)
```

For more examples, please refer to the [examples](examples) folder.

## Citation

Please cite [our paper](https://doi.org/10.1016/j.jmb.2026.169673) if you are using the *biocentral API* in your work:

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