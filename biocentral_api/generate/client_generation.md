# Client generation

This guide describes how the biocentral_server base API is generated from the OpenAPI specification
for each programming language.

## Installation

Make sure you have the [openapi-generator-cli](https://openapi-generator.tech/docs/installation) installed.
All commands are executed from the root of the project.

## Python

```shell
openapi-generator-cli generate \
  -g python \
  --package-name biocentral_server_api._generated \
  -i generate/openapi.json \
  -o python
 ```

Docs must be manually moved to docs/_generated at the moment.

## Dart

```shell
openapi-generator-cli generate \
  -g dart \
  -i generate/openapi.json \
  -o dart/
 ```

Then move all generated dart source files to `dart/lib/src/_generated`.