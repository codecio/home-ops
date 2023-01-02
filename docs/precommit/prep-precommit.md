# pre-commit and commitlint base setup

## Setup tools

Using homebrew:

    brew install pre-commit commitlint
    pre-commit --version
    commitlint --version

### pre-commit sample

Create `.pre-commit-config.yaml` at root.

    pre-commit sample-config > .pre-commit-config.yaml
    pre-commit install
    pre-commit run --all-files