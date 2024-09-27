# Biocentral Server Test Strategy

This document explains, how the server application and its endpoints should be tested.

## Running tests

Simply run:
```shell
pytest
```

## Unit tests

* Every "pure" and "independent" function (like e.g. `calculate_levenshtein_distances(sequences)`) must have unit tests
* All server_management classes should have unit tests
* Frontend functionality can have unit tests, but they are not strictly required

## Integration tests

* Every endpoint should have *at least one unit integration test* associated with it

Get a list of all endpoints:
```shell
find biocentral_server -type f -name "*_endpoint.py" | xargs grep -h "@.*_route.route" | sed -E "s/.*route\('([^']+)'.*\)/- [ ] \1/" | sort | uniq
```

## Contract tests

* Once the application shifted to a microservice architecture, there should be *at least one contract test* between
every interacting microservice
