# Biocentral Server API

## Introduction

To get started with the API, create a biocentral API object:

```python
from biocentral_api import BiocentralAPI

biocentral_api = BiocentralAPI().wait_until_healthy(max_wait_seconds=30)
```

## Core Features

### Embedding

You can embed sequences and use them directly in your script:
```python
from biocentral_api import CommonEmbedder

embedder_name = CommonEmbedder.ONE_HOT_ENCODING
reduce = True
sequence_data = {"Seq1": "MMALSLALM",
                 "Seq2": "PRTEIN",
                 "Seq3": "PRT",
                 "Seq4": "SEQWENCE",
                 "Seq5": "MMPRTEINSEQWENCE",
                 }
result = biocentral_api.embed(embedder_name=embedder_name, reduce=reduce, sequence_data=sequence_data,
                            use_half_precision=False).run()
```

The embedder name can also be a valid huggingface model name.
Below, you can find a list of the most common embedders supported by biocentral:

* ProtT5 = 'Rostlab/prot_t5_xl_uniref50'
* ProstT5 = 'Rostlab/ProstT5'
* ESM2_3B = 'facebook/esm2_t36_3B_UR50D'
* ESM2_650M = 'facebook/esm2_t33_650M_UR50D'
* ESM_8M = 'facebook/esm2_t6_8M_UR50D'
* ONE_HOT_ENCODING = 'one_hot_encoding'
* RANDOM_EMBEDDER = 'random_embedder'
* AAOntology = 'AAOntology'
* BLOSUM62 = 'blosum62'
