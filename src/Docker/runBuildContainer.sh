#!/bin/bash

# @description run the container specified by args provided.
# build and push the image if needed
#
# @env DOCKER_BUILD_OPTIONS
# @env SKIP_USER
# @env USER_ID
# @env GROUP_ID
# @env FRAMEWORK_ROOT_DIR
# @env DOCKER_OPTION_IMAGE_TAG
# @env BASH_FRAMEWORK_ARGV_FILTERED
Docker::runBuildContainer() {
  local optionVendor="$1"
  local optionBashVersion="$2"
  local optionBashBaseImage="$3"
  local optionSkipDockerBuild="$4"
  local optionTraceVerbose="$5"
  local optionContinuousIntegrationMode="$6"
  local -n localDockerRunCmd=$7
  local -n localDockerRunArgs=$8

  if [[ -d "$(pwd)/vendor/bash-tools-framework" ]]; then
    localDockerRunArgs+=(
      -v "$(cd "$(pwd)/vendor/bash-tools-framework" && pwd -P):/bash/vendor/bash-tools-framework"
    )
  fi

  # shellcheck disable=SC2154
  if [[ "${optionContinuousIntegrationMode}" = "0" ]]; then
    localDockerRunArgs+=(-v "/tmp:/tmp")
  fi
  localDockerRunArgs+=(-e KEEP_TEMP_FILES="${KEEP_TEMP_FILES}")
  localDockerRunArgs+=(-e BATS_FIX_TEST="${BATS_FIX_TEST:-0}")

  # shellcheck disable=SC2154
  Log::displayInfo "Using ${optionVendor}:${optionBashVersion}"

  local imageRef="${DOCKER_OPTION_IMAGE_TAG:-build:bash-tools-${optionVendor}-${optionBashVersion}}"
  if [[ "${optionSkipDockerBuild:-0}" != "1" ]]; then
    Log::displayInfo "Build docker image ${imageRef}"
    # shellcheck disable=SC2154
    (
      if [[ "${optionTraceVerbose}" = "1" ]]; then
        set -x
      fi
      Docker::buildPushDockerImage \
        "${optionVendor}" \
        "${optionBashVersion}" \
        "${optionBashBaseImage}" \
        "${optionPush}" \
        "${optionTraceVerbose}"
    )
  fi
  if [[ -f "${FRAMEWORK_ROOT_DIR}/.docker/DockerfileUser" ]]; then
    local imageRefUser="${imageRef}-user"
    if [[ "${optionSkipDockerBuild:-0}" != "1" ]]; then
      Log::displayInfo "build docker image ${imageRefUser} with user configuration"
      # shellcheck disable=SC2154
      (
        if [[ "${optionTraceVerbose}" = "1" ]]; then
          set -x
        fi
        # shellcheck disable=SC2086
        DOCKER_BUILDKIT=1 docker build \
          ${DOCKER_BUILD_OPTIONS} \
          --cache-from "scrasnups/${imageRef}" \
          --build-arg "BASH_IMAGE=scrasnups/${imageRef}" \
          --build-arg SKIP_USER="${SKIP_USER:-0}" \
          --build-arg USER_ID="${USER_ID:-$(id -u)}" \
          --build-arg GROUP_ID="${GROUP_ID:-$(id -g)}" \
          -f "${FRAMEWORK_ROOT_DIR}/.docker/DockerfileUser" \
          -t "${imageRefUser}" \
          "${FRAMEWORK_ROOT_DIR}/.docker"
      )
    fi
  fi

  Log::displayDebug "Run container with localDockerRunCmd: ${localDockerRunCmd[*]}"
  Log::displayDebug "Run container with localDockerRunArgs: ${localDockerRunArgs[*]}"
  Log::displayDebug "Run container with BASH_FRAMEWORK_ARGV_FILTERED: ${BASH_FRAMEWORK_ARGV_FILTERED[*]}"
  (
    # shellcheck disable=SC2154
    if [[ "${optionTraceVerbose}" = "1" ]]; then
      set -x
    fi
    # shellcheck disable=SC2086
    docker run \
      --rm \
      "${localDockerRunArgs[@]}" \
      ${DOCKER_RUN_OPTIONS} \
      -w /bash \
      -v "$(pwd):/bash" \
      --user "${USER_ID:-$(id -u)}:${GROUP_ID:-$(id -g)}" \
      "${imageRefUser}" \
      "${localDockerRunCmd[@]}"
  )
}
