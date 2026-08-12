# Biocentral

<p align="center">
  <img alt="biocentral logo" src="_global/design/biocentral_logo.png" />
<br />
Biomedical data, from lab to paper.
</p>

## About

Biocentral provides a rich ecosystem for connecting biomedical data and machine learning.

## Quick Start

### Frontend (Integrated Research Environment)

Use now in your browser at [https://app.biocentral.cloud](https://app.biocentral.cloud)!

### Python API

```shell
pip install biocentral
```

```python
from biocentral import Biocentral

biocentral = Biocentral(mode="api")  # Or local for execution on your machine
embeddings = biocentral.embed(embedder_name="Rostlab/ProstT5", sequence_data={"Seq1": "PRTEIN"})
```

### Documentation

For more use cases, examples and documentation see our [docs](https://docs.biocentral.cloud).

## 📄 License

Biocentral is open-source software licensed under the GNU General Public License v3.0. See the [LICENSE file](LICENSE)
for details.

## 📜 Citation

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
  publisher = {Elsevier BV},
}
```

