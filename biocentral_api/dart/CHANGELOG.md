## 2.1.0

- Added engineering simulation API with mutation descriptors and delta embeddings
- Added live HBI evaluation pipeline with API client models and serializers
- Added perplexity endpoint support
- Added clustering task APIs
- Regenerated Python and Dart clients for engineering simulations and mutations
- Improved error handling for unprocessable entity responses
- Various dependency updates and code cleanup

## 2.0.0

- Implements clustering task APIs for both Dart and Python.
- Updates dependencies to use the latest `biotrainer-core` from PyPI.
- Refactors Python code to leverage `biotrainer-core`'s unified sequence input handling.
- Adds support for generating `ProjectionResult` and introduces the `project` method in the `BiocentralAPI`.
- Adapts code to various server-side API updates, including validation for `embedder_name`.
- Refactors Python test cases and APIs to align with `biotrainer-core`.
- Enhances error handling for unprocessable entity responses.
- Updates and fixes imports, examples, and configurations to reflect API changes.

## 1.2.1

- Python Updates Only

## 1.2.0

- Adding support for UdonPred model
- Improving active learning API handling and enum support

## 1.1.2

- Upgrading to biocentral_server version 1.1.1

## 1.1.1

- Python Updates Only

## 1.1.0

- Review release

## 1.0.0

- Initial release of the dart api package.
