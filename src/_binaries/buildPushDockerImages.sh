#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/buildPushDockerImages
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options.buildPushDockerImages.tpl)"

buildPushDockerImagesCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

# build image and push it ot registry
run() {
  DOCKER_BUILD_OPTIONS="${DOCKER_BUILD_OPTIONS:-}"

  # pull image if needed
  # shellcheck disable=SC2154
  if [[ "${argBranchName}" != 'refs/heads/master' ]]; then
    docker pull "scrasnups/build:bash-tools-${argVendor}-${argBashTarVersion}" || true
  fi

  # shellcheck disable=SC2086,SC2154
  DOCKER_BUILDKIT=1 docker build \
    ${DOCKER_BUILD_OPTIONS} \
    -f "${BASH_TOOLS_ROOT_DIR:-${FRAMEWORK_ROOT_DIR}}/.docker/Dockerfile.${argVendor}" \
    --cache-from "scrasnups/build:bash-tools-${argVendor}-${argBashTarVersion}" \
    --build-arg BUILDKIT_INLINE_CACHE=1 \
    --build-arg argBashTarVersion="${argBashTarVersion}" \
    --build-arg BASH_IMAGE="${argBashBaseImage}" \
    -t "bash-tools-${argVendor}-${argBashTarVersion}" \
    -t "scrasnups/build:bash-tools-${argVendor}-${argBashTarVersion}" \
    "${BASH_TOOLS_ROOT_DIR:-${FRAMEWORK_ROOT_DIR}}/.docker"
  docker run --rm "bash-tools-${argVendor}-${argBashTarVersion}" bash --version

  # shellcheck disable=SC2154
  if [[ "${optionPush}" == "1" ]]; then
    docker push "scrasnups/build:bash-tools-${argVendor}-${argBashTarVersion}"
  fi
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
