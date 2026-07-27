# Biocentral Test Strategy

This document explains, how the main application and plugins should be tested.

## Running tests

Simply run:
```shell
flutter test # Unit and widget tests
flutter test integration_test # Integration and end-2-end tests
```

## Unit tests

Unit tests should be written *generously* for the following areas:
* data/*_api.dart => **Anything related to handling files from user input or the server**
* model => **Any class (besides plain data classes or enums) or functionality in the model should have unit tests**
* bloc => **Any bloc should have unit tests**

## Widget tests

*At least one widget test* should be written for the following widgets:
* **Any widget in the _sdk_**

Widget tests for plugin widgets can be added but *are not strictly required*.

## Integration tests

For each plugin, there should be *at least one integration test*, testing the core functionality of the plugin.
In addition, integration tests should be written to test the communication between different plugins *if applicable*,
and the communication between server and client *if applicable*.

## End-2-End tests

End-2-end tests should test the entire functionality of biotrainer by emulating user workflows:
* Each tutorial should come with *one* e2e test that resembles the tutorial training
