# pre-commit and commitlint base setup

I wanted to test out this combo setup of commintlint + pre-commit. Seems neat.

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

### commitlint sample

    npm install --save-dev @commitlint/{config-conventional,cli}
    echo "module.exports = {extends: ['@commitlint/config-conventional']};" > commitlint.config.js
    npm install husky --save-dev
    npx husky install
    npx husky add .husky/commit-msg  'npx --no -- commitlint --edit ${1}'
