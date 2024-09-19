# Contributing to biocentral

First off, a very warm thank you for considering contributing to `biocentral`! It is people like you,
living the spirit of open source software, that will make a difference.

## How Can I Contribute?

### Reporting Bugs

- Ensure the bug was not already reported by searching on GitHub
  under [Issues](https://github.com/biocentral/biocentral/issues).
- If you're unable to find an open issue addressing the
  problem, [open a new one](https://github.com/biocentral/biocentral/issues/new). Be sure to include a title and clear
  description, as much relevant information as possible, and a code sample or an executable test case demonstrating the
  expected behavior that is not occurring.

### Suggesting Enhancements

- Open a new issue with a clear title and detailed description of the suggested enhancement.

## GitFlow Workflow

At first, please create a fork of the repository in your own account. All PRs will be re-based on the development
branch of this main repository (see below).
We use a modified GitFlow workflow for this project. Here's an overview of the process:

### Main Branches

- `main`: This branch contains production-ready code. All releases are merged into `main` and tagged with a version
  number.
- `develop`: This is our main development branch. All features and non-emergency fixes are merged here.

### Supporting Branches

- Feature Branches:
    - Name format: `<plugin_name>/feature/your-feature-name`
    - Branch off from: `develop`
    - Merge back into: `develop`
    - Used for developing new features or enhancements.

- Bugfix Branches:
    - Name format: `<plugin_name>/bugfix/issue-description`
    - Branch off from: `develop`
    - Merge back into: `develop`
    - Used for fixing non-critical bugs.

- Release Branches:
    - Name format: `<plugin_name>/release/vX-Y-Z`
    - Branch off from: `develop`
    - Merge back into: `develop` and `main`
    - Used for preparing a new production release.

- Hotfix Branches:
    - Name format: `<plugin_name>/hotfix/issue-description`
    - Branch off from: `main`
    - Merge back into: `develop` and `main`
    - Used for critical bugfixes that need to be addressed immediately.

If your contribution concerns the whole project or just the core biocentral application, please use 
`biocentral/` instead of `<plugin_name>/` as prefix.

### Workflow Steps

1. For a new feature or non-critical bug fix:
    - Create a new feature or bugfix branch from `develop`.
    - Work on your changes in this branch.
    - When ready, create a pull request to merge your branch into `develop`.

2. For preparing a release:
    - Create a release branch from `develop`.
    - Make any final adjustments, version number updates, etc.
    - Create a pull request to merge the release branch into `main`.
    - After merging into `main`, also merge back into `develop`.
    - Tag the merge commit in `main` with the version number.

3. For critical hotfixes:
    - Create a hotfix branch from `main`.
    - Make your fixes.
    - Create a pull request to merge into `main`.
    - After merging into `main`, also merge into `develop`.
    - Tag the merge commit in `main` with an updated version number.

### Pull Requests

1. Ensure your code adheres to the project's coding standards.
2. Update the README.md with details of changes to the interface, if applicable.
3. Increase the version numbers in any examples files and the README.md to the new version that this Pull Request would
   represent. The versioning scheme we use is [SemVer](http://semver.org/).
4. You may merge the Pull Request in once you have the sign-off of one other developer, or if you do not have
   permission to do that, you may request the reviewer to merge it for you.

## Developer Certificate of Origin and Licensing

It must be ensured that everyone submitting a contribution to this repository is allowed to do this and does not violate 
copyrights of someone else. For that purpose you have to do some steps to meet our DCO requirements:

1. Read our [contributors file](Contributors.md) carefully.
2. Open a pull request which adds you to the [contributors file](Contributors.md) to agree to the DCO.
3. Always add a signed-off tag to all your commits as described in the [contributors file](Contributors.md).

## Styleguides

### Git Commit Messages

- Use the present tense ("Adding feature" not "Added feature")
- Limit the first line to 72 characters or fewer
- Reference issues and pull requests liberally after the first line

### Dart/Flutter

* Name callbacks with on: onOpenXYZ, onUpdatedXYZ...
* Organize widget states like this:
  1. Operational functions (like open dialog, initState)
  2. Build method (the standard flutter widget build method)
  3. Separated widget functions (any function that returns a widget as result)
* Close dialogs before adding events to the bloc or eventBus or executing callbacks

### Documentation Styleguide

- Use [Markdown](https://daringfireball.net/projects/markdown/) for documentation.

## Additional Notes

### Issue and Pull Request Labels

This section lists the labels we use to help us track and manage issues and pull requests.

* `bug` - Issues that are bugs.
* `enhancement` - Issues that are feature requests.
* `documentation` - Issues or pull requests related to documentation.
* `maintenance` -  If you update parts of the project to newer versions, e.g. dependency updates or fixing examples.
* `good first issue` - Good for newcomers.
* `name_of_plugin` - Everything related to a specific plugin.

Thank you for contributing to `biocentral`!
