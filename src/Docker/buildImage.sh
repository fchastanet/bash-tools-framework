#!/usr/bin/env bash

# try to docker build image from eventual tagged image cache
# - Using DOCKER_BUILDKIT=1
# - Using BUILDKIT_INLINE_CACHE in order to use the resulting image as a cache source
# @see https://docs.docker.com/engine/reference/commandline/build/#specifying-external-cache-sources
#
# You can specify cacheFrom options using the method Docker::getBuildCacheFromArg
# Eg:
#   # notice that there is no double quotes around $(Docker::getBuildCacheFromArg bash-tools:tag1 bash-tools:tag2)
#   Docker::buildImage "." "Dockerfile" "bash-tools" $(Docker::getBuildCacheFromArg bash-tools:tag1 bash-tools:tag2)
#
# @param {String} buildDirectory $1 base directory from where Dockerfile will take hits resources
# @param {String} dockerFilePath $2 docker file path
# @param {String} localImageName $3 the local image name of the resulting image (eg: in ubuntu:latest, ubuntu is the image name
# @param {mixed}  ... $@ rest of the parameters to pass to docker build method
# @return 1 if buildDirectory does not exists
# @return 2 if dockerFilePath does not exists
# @return 3 if empty or invalid localImageName
# @output {String} the tag that has been successfully pulled, return 1 if none
Docker::buildImage() {
  local buildDirectory="$1"
  shift || true
  local dockerFilePath="$1"
  shift || true
  local localImageName="$1"
  shift || true
  if [[ ! -d "${buildDirectory}" ]]; then
    Log::displayError "Build directory invalid '${buildDirectory}'"
    return 1
  fi

  if [[ ! -f "${dockerFilePath}" ]]; then
    Log::displayError "Dockerfile path invalid '${dockerFilePath}'"
    return 2
  fi

  if [[ -z "${localImageName}" ]]; then
    Log::displayError "empty localImageName"
    return 3
  fi

  DOCKER_BUILDKIT=1 docker build \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    -f "${dockerFilePath}" \
    -t "${localImageName}" \
    "$@" \
    "${buildDirectory}"
}
