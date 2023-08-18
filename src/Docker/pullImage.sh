#!/usr/bin/env bash

# @description try to docker pull image from pullTags arg
# best practice: provide tags 'tagPrefix_shortSha' 'tagPrefix_branchName'
# so image will be tagged with
# - tagPrefix_shortSha
# - tagPrefix_branchName
# @arg $1 registryImageUrl:String eg:889859566884.dkr.ecr.eu-west-1.amazonaws.com/bast-tools-dev-env
# @arg $@ tags:String[] list of tags used to pull image from docker registry
# @exitcode 1 if tags list is empty or on on invalid argument
# @exitcode 2 if no image pulled
# @stdout {String} the tag that has been successfully pulled, return 1 if none
# @stderr diagnostics information is displayed
# @require Docker::requireDockerCommand
Docker::pullImage() {
  local registryImageUrl="$1"
  shift || true
  if [[ "$#" = "0" ]]; then
    Log::displayError "At least one tag should be provided"
    return 1
  fi
  local tag
  for tag in "$@"; do
    Log::displayInfo "docker pull ${registryImageUrl}:${tag}"
    if docker pull "${registryImageUrl}:${tag}" | sed -En 's#^Digest: sha256:(.+)$#\1#p'; then
      return 0
    fi
  done
  Log::displayError "No image pulled"
  return 2
}
