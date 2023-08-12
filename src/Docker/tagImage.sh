#!/usr/bin/env bash

# Image built is tagged with tags provided
# best practice: provide tags 'tagPrefix_shortSha' 'tagPrefix_branchName'
# so image will be tagged with
# - tagPrefix_shortSha
# - tagPrefix_branchName
# @arg $1 registryImageUrl:String eg:889859566884.dkr.ecr.eu-west-1.amazonaws.com/bast-tools-dev-env
# @arg $2 localTag:String the docker image local tag that needs to be remotely tagged (eg: bash-tools:latest)
# @arg $@ tags:String[] list of tags used to push image to docker registry
# @exitcode 1 if tags list is empty
Docker::tagImage() {
  local registryImageUrl="$1"
  shift || true
  local localTag="$1"
  shift || true
  if [[ "$#" = "0" ]]; then
    Log::displayError "At least one tag should be provided"
    return 1
  fi
  local tag
  for tag in "$@"; do
    docker tag "${localTag}" "${registryImageUrl}:${tag}"
  done
}
