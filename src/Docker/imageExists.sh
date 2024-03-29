#!/usr/bin/env bash

# @description Check if image is tagged on docker registry
# best practice: provide tags 'tagPrefix_shortSha' 'tagPrefix_branchName'
# so image will be tagged with
# - tagPrefix_shortSha
# - tagPrefix_branchName
# @arg $1 registryImageUrl:String eg:889859566884.dkr.ecr.eu-west-1.amazonaws.com/bast-tools-dev-env
# @arg $@ tags:String[] list of tags used to check if image exists on docker registry
# @exitcode 1 if at least one tag does not exist
# @stderr diagnostics information is displayed
# @require Docker::requireDockerCommand
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
