# biocentral_server Changelog

## v1.0.0

- Fixed configuration conversion issues and various `.env` path resolutions.
- Updated Prometheus configurations, adding support for a separate volume and time series metrics logging.
- Added features like rate limiting and a middleware for body size limitation (default: 200MB).
- Enhanced robustness in prediction endpoints, handling versatile input formats and refining how model input details are
  processed.
- Introduced support for exotox and new models such as "la membrane" and Vespag.
- Resolved async-related user ID retrieval issues and associated task DTO enhancements.
- Updated Docker-related files, improving setup and health checks in Docker Compose.
- Various refactorings for better structure, including moving temporary methods, cleaning unused modules, and
  transforming prediction and embedding handling.
- Paper submission version.

## v0.2.5

* Improving docker compose setup
* Adding initializers to handle external data download, storage and preprocessing
* Adding predict module with 8 new prediction models, a prediction and a metadata endpoint

## v0.2.0

* Greatly improving task handling by adding resume functionality
* Switching to docker compose setup, hence removing pyinstaller and frontend
* Improving AutoEval Task to plm leaderboard v2

## v0.1.2

* Adding embeddings database (PostgreSQL/TinyDB)
* Adding prototype of plm_eval module based on FLIP and auto_eval
* Improving process management

## v0.1.1

* Improving cross-platform compatibility (icon, building)
* Adding CI-pipeline for building, testing and release

## v0.1.0

* Initial alpha release
