#!/usr/bin/env bash

# Check if image is tagged on docker registry
# best practice: provide tags 'tagPrefix_shortSha' 'tagPrefix_branchName'
# so image will be tagged with
# - tagPrefix_shortSha
# - tagPrefix_branchName
# @param {String} registryImageUrl $1 eg:889859566884.dkr.ecr.eu-west-1.amazonaws.com/bast-tools-dev-env
# @param {String} tags $@ list of tags used to check if image exists on docker registry
# @return 1 if at least one tag does not exist
Docker::imageExists() {
  local registryImageUrl="$1"
  shift || true
  if [[ "$#" = "0" ]]; then
    Log::displayError "At least one tag should be provided"
    return 1
  fi
  local tag
  for tag in "$@"; do
    if ! docker manifest inspect "${registryImageUrl}:${tag}" >/dev/null; then
      Log::displayError "image with tag ${registryImageUrl}:${tag} does not exists"
      return 1
    fi
  done
}
