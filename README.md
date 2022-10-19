# workflows

### python-ci.yml

This workflow will check linting and run tests for a python project.

It assumes that the project dependencies are managed by Poetry version >= 1.2.x

Currently the workflow always starts a `postgres` service, so it's not yet modular nor compatible with projects that need another type of service, or no service at all (but these ones can just ignore the postgres service).

There are also several assumptions on the project directories:
- the project Makefile should contain the `make test` command
- source code should be in the `src` directory
- test code should be in the `tests` directory
- database migrations, if any, should be in the `db/migrations` directory and should follow [migrate](https://github.com/golang-migrate/migrate) standards

### python-cd.yml

This workflow will deploy a python project to _AWS_.
It's compatible with both **`dev`** and **`prod`** environments.

For `dev`, it will first **_build_** the project and push the resulting Docker image to the project ECR repository. To do so it expects to find a `Dockerfile` in the root of the project.

When necessary, it can also optionally build and push the project **_migrations_**, expecting a `Dockerfile.migrations` file placed in the `db/aws` directory.


## Usage

These workflows can be combined in a few different ways, but the most conventional approach is to create a file,  
for example `./.github/workflows/ci-cd.yml` that will cover the **continuous integration** (_i.e. linting_) for all pull requests towards `main`, as well as the **continuous deployment** in the `dev` environment.

```yaml
name: Lint, Test & Deploy to dev

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  ci:
    uses: mirta-com/workflows/.github/workflows/python-ci.yml@main
    secrets: inherit

  cd:
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    needs: ci
    uses: mirta-com/workflows/.github/workflows/python-cd.yml@main
    secrets: inherit
    with:
      SERVICE_NAME: foobar
      ENV: dev
      GIT_REF: ${{ github.sha }}
      AWS_ACCOUNT: 999999999
      AWS_REGION: eu-west-1
      AWS_ROLE_TO_ASSUME: demo-aws-iam-role-name
      SLACK_CHANNEL: demo-slack-channel
```

A second file, for example `./.github/workflows/cd.prod.yml`, could be dedicated to the deploy in the `prod` environment.

```yaml
name: Deploy to prod

on:
  workflow_dispatch:
    inputs:
      gitRef:
        description: "Git SHA commit to be deployed"
        required: true

jobs:
  prod:
    uses: mirta-com/workflows/.github/workflows/python-cd.yml@main
    secrets: inherit
    with:
      SERVICE_NAME: foobar
      ENV: prod
      GIT_REF: ${{ inputs.gitRef }}
      AWS_ACCOUNT: 999999999
      AWS_REGION: eu-west-1
      AWS_ROLE_TO_ASSUME: demo-aws-iam-role-name
      SLACK_CHANNEL: demo-slack-channel
```
