#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/runBuildContainer
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options/command.runBuildContainer.tpl)"

declare -a dockerRunCmd=()
declare -a dockerRunArgs=()
declare -a dockerRunArgs=(-e KEEP_TEMP_FILES="${KEEP_TEMP_FILES}")
export DOCKER_BUILD_OPTIONS="${DOCKER_BUILD_OPTIONS:-}"
export DOCKER_RUN_OPTIONS="${DOCKER_RUN_OPTIONS:-}"

runBuildContainerCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

if tty -s; then
  dockerRunArgs+=("-it")
fi
if [[ -d "$(pwd)/vendor/bash-tools-framework" ]]; then
  dockerRunArgs+=(
    -v "$(cd "$(pwd)/vendor/bash-tools-framework" && pwd -P):/bash/vendor/bash-tools-framework"
  )
fi

# shellcheck disable=SC2154
if [[ "${optionContinuousIntegrationMode}" = "0" ]]; then
  dockerRunArgs+=(-v "/tmp:/tmp")
fi

run() {
  # shellcheck disable=SC2154
  Log::displayInfo "Using ${optionVendor}:${optionBashVersion}"

  imageRef="bash-tools-${optionVendor}-${optionBashVersion}"
  if [[ "${optionSkipDockerBuild:-0}" != "1" ]]; then
    Log::displayInfo "Build docker image ${imageRef}"
    # shellcheck disable=SC2154
    (
      if [[ "${optionTraceVerbose}" = "1" ]]; then
        set -x
      fi
      "${FRAMEWORK_BIN_DIR}/buildPushDockerImage" \
        --vendor "${optionVendor}" \
        --bash-version "${optionBashVersion}" \
        --bash-base-image "${optionBashBaseImage}" \
        "${RUN_CONTAINER_ARGV_FILTERED[@]}"
    )
  fi
  if [[ -f "${FRAMEWORK_ROOT_DIR}/.docker/DockerfileUser" ]]; then
    imageRef="${imageRef}-user"
    if [[ "${optionSkipDockerBuild:-0}" != "1" ]]; then
      Log::displayInfo "build docker image ${imageRef} with user configuration"
      # shellcheck disable=SC2154
      (
        if [[ "${optionTraceVerbose}" = "1" ]]; then
          set -x
        fi
        # shellcheck disable=SC2086
        DOCKER_BUILDKIT=1 docker build \
          ${DOCKER_BUILD_OPTIONS} \
          --cache-from "scrasnups/build:${imageRef}" \
          --build-arg "BASH_IMAGE=${imageRef}:latest" \
          --build-arg SKIP_USER="${SKIP_USER:-0}" \
          --build-arg USER_ID="${USER_ID:-$(id -u)}" \
          --build-arg GROUP_ID="${GROUP_ID:-$(id -g)}" \
          -f "${FRAMEWORK_ROOT_DIR}/.docker/DockerfileUser" \
          -t "${imageRef}" \
          "${FRAMEWORK_ROOT_DIR}/.docker"
      )
    fi
  fi

  Log::displayInfo "Run container with command: '${dockerRunCmd[*]} ${RUN_CONTAINER_ARGV_FILTERED[*]}'"
  (
    # shellcheck disable=SC2154
    if [[ "${optionTraceVerbose}" = "1" ]]; then
      set -x
    fi
    # shellcheck disable=SC2086
    docker run \
      --rm \
      ${DOCKER_RUN_OPTIONS} \
      "${dockerRunArgs[@]}" \
      -w /bash \
      -v "$(pwd):/bash" \
      --user "${USER_ID:-$(id -u)}:${GROUP_ID:-$(id -g)}" \
      "${imageRef}" \
      "${dockerRunCmd[@]}" \
      "${RUN_CONTAINER_ARGV_FILTERED[@]}"
  )
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
