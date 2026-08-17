from biocentral import Biocentral

# biocentral

This is the *biocentral* python package, providing all functionality of the biocentral ecosystem in one package.

## Installation

Install from [pypi](https://pypi.org/project/biocentral/) using pip:
```shell
pip install biocentral
```

If you want to deploy your own [server](https://github.com/biocentral/biocentral/tree/main/biocentral_server), 
add the *server* extra:
```shell
pip install biocentral[server]
```

If you want to run local functionality, add the *local* extra:
```shell
pip install biocentral[local]
```

*Note that local and server install require large dependencies, while the default mode is minimal and lightweight.*

## Quick Start

1. Create a biocentral object:
```python
from biocentral import Biocentral

biocentral = Biocentral(mode="api")  # or "local"
```

2. Visualize some data:
```python
from biocentral import BiocentralChart
from biotrainer_core.input_files import read_FASTA

sequence_data = read_FASTA("your_sequences.fasta")

sequence_length_distribution = BiocentralChart.sequence_length_distribution(sequence_data)
sequence_length_distribution.chart.interactive()
```

3. Embed the sequences via a *protein language model*:
```python
embeddings = biocentral.embed(embedder_name="Rostlab/ProstT5", sequence_data=sequence_data, reduce=True)
print(embeddings)
```

Find more examples in the [examples directory](examples)!

## License

This package is subject to the [MIT License](LICENSE).