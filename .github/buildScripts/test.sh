#!/usr/bin/env bash

set -o errexit
set -o pipefail
CURRENT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

# use this in order to debug inside the container
# docker build -t bash-tools-ubuntu:5.1 -f .docker/Dockerfile.ubuntu
# docker run --rm -it -v "$(pwd):/bash"  --user "$(id -u):$(id -g)"  bash-tools-ubuntu-5.1-user bash
# docker run --rm -it -v "$(pwd):/bash"  --user "$(id -u):$(id -g)"  bash-tools-alpine-5.1-user bash
#
# to force image rebuilding
# DOCKER_BUILD_OPTIONS=--no-cache ./test.sh 
#
# rebuild alpine image
# DOCKER_BUILD_OPTIONS=--no-cache VENDOR=alpine BASH_IMAGE=bash:5.1 BASH_TAR_VERSION=5.1 ./test.sh 

if [ "${IN_BASH_DOCKER:-}" = "You're in docker" ]; then
  (
    if (( $# < 1)); then
      "${CURRENT_DIR}/vendor/bats/bin/bats" -r tests
    else
      "${CURRENT_DIR}/vendor/bats/bin/bats" "$@"
    fi
  )
else
  "${CURRENT_DIR}/.build/runBuildContainer.sh" "/bash/test.sh" "$@"
fi
