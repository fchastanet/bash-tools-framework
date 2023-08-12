#!/usr/bin/env bash

# generate list of --cache-from arg to pass to docker build
# @arg $@ tags:String[] list of tags to use as cache
# @stdout string representing arguments to pass to Docker::buildImage to build image using cache
# @see Docker::buildImage
Docker::getBuildCacheFromArg() {
  local tag
  for tag in "$@"; do
    [[ -n "${tag}" ]] && echo -n "--cache-from='${tag}' "
  done
}
