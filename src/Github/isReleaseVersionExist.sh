#!/usr/bin/env bash

# @description check if specified release software version exists in github
# @arg $1 releaseUrl:String eg: https://github.com/kubernetes-sigs/kind/releases/download/v1.0.0/kind-linux-amd64
# @exitcode 1 on failure
# @exitcode 0 if release version exists
# @env CURL_CONNECT_TIMEOUT number of seconds before giving up host connection
Github::isReleaseVersionExist() {
  local releaseUrl="$1"

  curl \
    -L \
    --connect-timeout "${CURL_CONNECT_TIMEOUT:-5}" \
    -o /dev/null \
    --silent \
    --head \
    --fail \
    "${releaseUrl}"
}
