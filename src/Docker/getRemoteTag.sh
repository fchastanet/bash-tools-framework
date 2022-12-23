#!/usr/bin/env bash

# @param {String} remoteUrl $1 eg: id.dkr.ecr.eu-west-1.amazonaws.com
# @param {String} imageName $2 eg: bash-tools
# @param {String} tag $3
# @stdout a string representing a docker remote tag
Docker::getRemoteTag() {
  local remoteUrl="$1"
  local imageName="$2"
  local tag="$3"
  echo "${remoteUrl}/${imageName}:${tag}"
}
