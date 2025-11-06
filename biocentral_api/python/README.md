# biocentral_api - Python Client

Python API package for biocentral.

## Installation

```shell
pip install biocentral_api
```

## Basic Usage

**Embedding protein sequences**:
```python
from biocentral_api import BiocentralAPI

biocentral_api = BiocentralAPI()

# ProtT5
embedder_name = "Rostlab/prot_t5_xl_uniref50"
reduce = True
sequence_data = {"Seq1": "MMALSLALM"}
result = biocentral_api.embed(embedder_name=embedder_name, reduce=reduce, sequence_data=sequence_data,
                            use_half_precision=False).run()
print(result)
```

For more examples, please refer to the [examples](examples) folder.


