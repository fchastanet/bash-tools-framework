#!/usr/bin/env bash

# @arg $1 remoteUrl:String eg: id.dkr.ecr.eu-west-1.amazonaws.com
# @arg $2 imageName:String eg: bash-tools
# @arg $3 tag:String the tag to retrieve
# @stdout a string representing a docker remote tag
Docker::getRemoteTag() {
  local remoteUrl="$1"
  local imageName="$2"
  local tag="$3"
  echo "${remoteUrl}/${imageName}:${tag}"
}
