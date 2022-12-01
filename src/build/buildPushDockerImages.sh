#!/usr/bin/env bash
# BUILD_BIN_FILE=${ROOT_DIR}/build/buildPushDockerImages.sh

.INCLUDE lib/_header.tpl

# FUNCTIONS

VENDOR="$1"
BASH_TAR_VERSION="$2"
BASH_BASE_IMAGE="$3"
PULL_IMAGE="${4:-true}"
PUSH_IMAGE="${5:-}"
DOCKER_BUILD_OPTIONS="${DOCKER_BUILD_OPTIONS:-}"

if [[ -z "${VENDOR}" || -z "${BASH_TAR_VERSION}" || -z "${BASH_BASE_IMAGE}" ]]; then
  Log::fatal "please provide these parameters VENDOR, BASH_TAR_VERSION, BASH_BASE_IMAGE"
fi

cd "${ROOT_DIR}" || exit 1

# pull image if needed
if [[ "${PULL_IMAGE}" == "true" ]]; then
  docker pull "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}" || true
fi

# build image and push it ot registry
# shellcheck disable=SC2086
DOCKER_BUILDKIT=1 docker build \
  ${DOCKER_BUILD_OPTIONS} \
  -f ".docker/Dockerfile.${VENDOR}" \
  --cache-from "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}" \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg BASH_TAR_VERSION="${BASH_TAR_VERSION}" \
  --build-arg BASH_IMAGE="${BASH_BASE_IMAGE}" \
  -t "bash-tools-${VENDOR}-${BASH_TAR_VERSION}" \
  -t "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}" \
  ".docker"
docker run --rm "bash-tools-${VENDOR}-${BASH_TAR_VERSION}" bash --version

if [[ "${PUSH_IMAGE}" == "push" ]]; then
  docker push "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}"
fi
