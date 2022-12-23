#!/usr/bin/env bash

# Image exists with tags provided on AWS ecr
# best practice: provide tags 'tagPrefix_shortSha' 'tagPrefix_branchName'
# so image will be tagged with
# - tagPrefix_shortSha
# - tagPrefix_branchName
# @param {String} repositoryName $1 eg:889859566884.dkr.ecr.eu-west-1.amazonaws.com/bast-tools-dev-env
# @param {String} tags $@ list of tags used to check if image exists on AWS ECR
# @return 1 if no tag provided
# @return 2 if at least one tag does not exist
Aws::imageExists() {
  local repositoryName="$1"
  shift || true
  if [[ "$#" = "0" ]]; then
    Log::displayError "At least one tag should be provided"
    return 1
  fi
  local imageTag
  for imageTag in "$@"; do
    if ! aws ecr describe-images --repository-name="${repositoryName}" --image-ids=imageTag="${imageTag}" >/dev/null; then
      Log::displayError "image with tag ${repositoryName}:${imageTag} does not exists"
      return 2
    fi
  done
}
