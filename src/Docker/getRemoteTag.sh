#!/usr/bin/env bash

# @description generates a string representing a docker remote tag
# @example text
#   id.dkr.ecr.eu-west-1.amazonaws.com/bash-tools:v1.0.0
# @arg $1 remoteUrl:String eg: id.dkr.ecr.eu-west-1.amazonaws.com
# @arg $2 imageName:String eg: bash-tools
# @arg $3 tag:String the tag to retrieve (eg: v1.0.0)
# @stdout a string representing a docker remote tag
# @require Docker::requireDockerCommand
Docker::getRemoteTag() {
  local remoteUrl="$1"
  local imageName="$2"
  local tag="$3"
  echo "${remoteUrl}/${imageName}:${tag}"
}
