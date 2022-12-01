#!/usr/bin/env bash

#####################################
# GENERATED FILE FROM src/build/runBuildContainer.sh
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

VENDOR="${VENDOR:-ubuntu}"
BASH_TAR_VERSION="${BASH_TAR_VERSION:-5.1}"
BASH_IMAGE="${BASH_IMAGE:-ubuntu:20.04}"
DOCKER_BUILD_OPTIONS="${DOCKER_BUILD_OPTIONS:-}"

(echo >&2 "run tests using ${VENDOR}:${BASH_TAR_VERSION}")
cd "${ROOT_DIR}" || exit 1

if [[ ! -d "${ROOT_DIR}/vendor" ]]; then
  ./.build/installBuildDeps.sh
fi

if [[ "${SKIP_BUILD:-0}" = "0" ]]; then
  ./.build/buildPushDockerImages.sh "${VENDOR}" "${BASH_TAR_VERSION}" "${BASH_IMAGE}"

  # build docker image with user configuration
  # shellcheck disable=SC2086
  docker build \
    ${DOCKER_BUILD_OPTIONS} \
    --build-arg "BASH_IMAGE=bash-tools-${VENDOR}-${BASH_TAR_VERSION}:latest" \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    -f .docker/DockerfileUser \
    -t "bash-tools-${VENDOR}-${BASH_TAR_VERSION}-user" \
    ".docker"
fi

# run tests
args=()
if tty -s; then
  args=("-it")
fi

docker run \
  --rm \
  "${args[@]}" \
  -w /bash \
  -v "${ROOT_DIR}:/bash" \
  --user "$(id -u):$(id -g)" \
  "bash-tools-${VENDOR}-${BASH_TAR_VERSION}-user" \
  "$@"
