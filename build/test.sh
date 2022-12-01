#!/usr/bin/env bash

#####################################
# GENERATED FILE FROM src/build/test.sh
# DO NOT EDIT IT
#####################################

ROOT_DIR="/home/wsl/projects/bash-tools2"
# shellcheck disable=SC2034
LIB_DIR="${ROOT_DIR}/lib"
# shellcheck disable=SC2034

# shellcheck disable=SC2034
((failures = 0)) || true

shopt -s expand_aliases
set -o pipefail
set -o errexit
# a log is generated when a command fails
set -o errtrace
# use nullglob so that (file*.php) will return an empty array if no file matches the wildcard
shopt -s nullglob
export TERM=xterm-256color

#avoid interactive install
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# FUNCTIONS

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

if [[ "${IN_BASH_DOCKER:-}" = "You're in docker" ]]; then
  (
    if (($# < 1)); then
      "${ROOT_DIR}/vendor/bats/bin/bats" -r tests
    else
      "${ROOT_DIR}/vendor/bats/bin/bats" "$@"
    fi
  )
else
  "${ROOT_DIR}/.build/runBuildContainer.sh" "/bash/test.sh" "$@"
fi
