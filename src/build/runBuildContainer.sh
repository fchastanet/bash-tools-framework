#!/usr/bin/env bash
# BUILD_BIN_FILE=${ROOT_DIR}/build/runBuildContainer.sh

.INCLUDE lib/_header.tpl

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
