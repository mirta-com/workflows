#!/usr/bin/env sh
set -e

_ENV="${DEPLOY_ENV:-dev}"
_ACCOUNT="${AWS_ACCOUNT?AccountID is required}"
_REGION="${AWS_REGION:-eu-west-1}"
_PROJECT_ID="${PROJECT_ID?ProjectID is required}"
_TEMPLATE_PATH="${TEMPLATE_PATH?TemplatePath is required}"
_VERSION="${VERSION?Version is required}"
_REPO="${IMAGE_REPO?Image repo is required}"
_TAG="${IMAGE_TAG?Image tag is required}"

sam deploy \
    --image-repository ${_REPO} \
    --parameter-overrides "NameSpace=mirta Env=${_ENV} Account=${_ACCOUNT} Region=${_REGION} Version=${_VERSION} ImageTag=${_TAG} DeployTimestamp=$(date +%s)" \
    --stack-name "${_PROJECT_ID}-${_ENV}" \
    --template-file ${_TEMPLATE_PATH} \
    --no-fail-on-empty-changeset \
    --no-confirm-changeset \
    --tags "cloudformed=true environment=${_ENV} domain=${_PROJECT_ID} project=${_PROJECT_ID}"
