#!/usr/bin/env bash

# try to docker pull image from pullTags arg
# best practice: provide tags 'tagPrefix_shortSha' 'tagPrefix_branchName'
# so image will be tagged with
# - tagPrefix_shortSha
# - tagPrefix_branchName
# @param {String} registryImageUrl $1 eg:889859566884.dkr.ecr.eu-west-1.amazonaws.com/bast-tools-dev-env
# @param {String} tags $@ list of tags used to pull image from docker registry
# @return 1 if tags list is empty or on on invalid argument
# @return 2 if no image pulled
# @output {String} the tag that has been successfully pulled, return 1 if none
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
    if docker pull "${registryImageUrl}:${tag}" | sed -nr 's#^Digest: sha256:(.+)$#\1#p'; then
      return 0
    fi
  done
  Log::displayError "No image pulled"
  return 1
}
