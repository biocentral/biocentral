# Biocentral Changelog

## v1.0.0

Paper release version.

- **Functionality Enhancements**
    - BiocentralConfigDialog and BiocentralRatioSlider added for unified configuration management and value selection.
    - Improved handling of training data and protein repository examples.
    - Advanced model comparison features and updates to metrics plots.
- **Refactoring**
    - Significant restructuring of config dialogs and event handlers.
    - Adaptation to updated ProtSpace and biotrainer APIs.
    - Creation of reusable components, e.g., `BiocentralDialogCloseMixin` for dialog operations.
    - Renaming and aligning modules consistently (e.g., `prediction_models` to `custom_models`).
    - Upgrading Flutter version
- **Bug Fixes**
    - Issues with embedding save names, projection APIs, tooltips, and type conversions resolved.
    - Improved error-handling mechanisms in visualization and column wizard operations.
- **UI/UX Improvements**
    - Enhanced tooltips, explanations, and future-proofing text in column wizards.


## v0.2.5
* Fixing project loading race condition
* Adding command to load existing plm eval persistent result
* Fixing incorrect type check in plm leaderboard parsing
* **Adding first version of prototype for bayesian optimization plugin** (@arnoclaude @yemlihaoner)

## v0.2.0
* Creating adaptions to refactored server, including a new resume task functionality
* Adding a python companion to be able to perform python-specific operations locally, such as embeddings handling
* Largely improving the plm_eval module

## v0.1.2
* Improving column wizard plots
* Adding prototype for plm evaluate plugin
* Applying new linter rules
* Improving prediction model display
* Improving build and release workflows

## v0.1.1
* Adding welcome dialog
* Adding tooltips to all command buttons
* Adding a testing strategy and some first tests
* Improving cross-platform builds

## v0.1.0
* Initial alpha release