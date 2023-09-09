#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/buildPushDockerImage
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options/command.buildPushDockerImage.tpl)"

buildPushDockerImageCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

# build image and push it ot registry
run() {
  DOCKER_BUILD_OPTIONS="${DOCKER_BUILD_OPTIONS:-}"
  # shellcheck disable=SC2154
  local imageTag="build:bash-tools-${optionVendor}-${optionBashVersion}"
  local image="scrasnups/${imageTag}"

  Log::displayInfo "Pull image ${image}"
  # shellcheck disable=SC2154
  (
    if [[ "${optionTraceVerbose}" = "1" ]]; then
      set -x
    fi
    docker pull "${image}" || true
  )

  Log::displayInfo "Build image ${image}"
  # shellcheck disable=SC2086,SC2154
  (
    # shellcheck disable=SC2154
    if [[ "${optionTraceVerbose}" = "1" ]]; then
      set -x
    fi
    DOCKER_BUILDKIT=1 docker build \
      ${DOCKER_BUILD_OPTIONS} \
      -f "${BASH_TOOLS_ROOT_DIR:-${FRAMEWORK_ROOT_DIR}}/.docker/Dockerfile.${optionVendor}" \
      --cache-from "${image}" \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --build-arg argBashVersion="${optionBashVersion}" \
      --build-arg BASH_IMAGE="${optionBashBaseImage}" \
      -t "${imageTag}" \
      -t "${image}" \
      "${BASH_TOOLS_ROOT_DIR:-${FRAMEWORK_ROOT_DIR}}/.docker"
  )

  Log::displayInfo "Image ${image} - bash version check"
  docker run --rm "bash-tools-${optionVendor}-${optionBashVersion}" bash --version

  # shellcheck disable=SC2154
  if [[ "${optionPush}" = "1" ]]; then
    Log::displayInfo "Push image ${image}"
    (
      if [[ "${optionTraceVerbose}" = "1" ]]; then
        set -x
      fi
      docker push "scrasnups/build:bash-tools-${optionVendor}-${optionBashVersion}"
    )
  fi
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
