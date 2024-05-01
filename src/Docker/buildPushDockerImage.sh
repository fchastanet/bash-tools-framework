#!/bin/bash

# @description build image and push it to registry
# @env DOCKER_OPTION_IMAGE_TAG String computed from optionVendor and optionBashVersion if not provided
# @env DOCKER_OPTION_IMAGE String default scrasnups/${DOCKER_OPTION_IMAGE_TAG}
# @env DOCKER_BUILD_OPTIONS String list of docker arguments to pass to docker build command
# @env FRAMEWORK_ROOT_DIR String path allowing to deduce .docker/Dockerfile.{vendor}
Docker::buildPushDockerImage() {
  local optionVendor="$1"
  local optionBashVersion="$2"
  local optionBashBaseImage="$3"
  local optionPush="$4"
  local optionTraceVerbose="$5"
  # parameters based on env variables
  local imageTag="${DOCKER_OPTION_IMAGE_TAG:-build:bash-tools-${optionVendor}-${optionBashVersion}}"
  local image="${DOCKER_OPTION_IMAGE:-scrasnups/${imageTag}}"
  local DOCKER_BUILD_OPTIONS="${DOCKER_BUILD_OPTIONS:-}"

  Log::displayInfo "Pull image ${image}"
  (
    if [[ "${optionTraceVerbose}" = "1" ]]; then
      set -x
    fi
    docker pull "${image}" || true
  )

  Log::displayInfo "Build image ${image}"
  # shellcheck disable=SC2086
  (
    if [[ "${optionTraceVerbose}" = "1" ]]; then
      set -x
    fi
    DOCKER_BUILDKIT=1 docker build \
      ${DOCKER_BUILD_OPTIONS} \
      -f "${FRAMEWORK_ROOT_DIR}/.docker/Dockerfile.${optionVendor}" \
      --cache-from "${image}" \
      --build-arg BUILDKIT_INLINE_CACHE=1 \
      --build-arg argBashVersion="${optionBashVersion}" \
      --build-arg BASH_IMAGE="${optionBashBaseImage}" \
      -t "${imageTag}" \
      -t "${image}" \
      "${FRAMEWORK_ROOT_DIR}/.docker"
  )

  Log::displayInfo "Image ${image} - bash version check"
  docker run --rm "${imageTag}" bash --version

  # shellcheck disable=SC2154
  if [[ "${optionPush}" = "1" ]]; then
    Log::displayInfo "Push image ${image}"
    (
      if [[ "${optionTraceVerbose}" = "1" ]]; then
        set -x
      fi
      docker push "scrasnups/${imageTag}"
    )
  fi
}
