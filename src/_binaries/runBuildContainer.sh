#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/runBuildContainer
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

showHelp() {
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} run the container specified by args provided.
Command to run is passed via the rest of arguments
TTY allocation is detected automatically

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} <vendor> <bash_tar_version> <bash_base_image> <bash_image> ...
additional docker build options can be passed via DOCKER_BUILD_OPTIONS env variable
additional docker run options can be passed via DOCKER_RUN_OPTIONS env variable

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
}
Args::defaultHelp showHelp "${BASH_FRAMEWORK_ARGV[@]}" || true

VENDOR="${VENDOR:-ubuntu}"
BASH_TAR_VERSION="${BASH_TAR_VERSION:-5.1}"
BASH_IMAGE="${BASH_IMAGE:-ubuntu:20.04}"
DOCKER_BUILD_OPTIONS="${DOCKER_BUILD_OPTIONS:-}"

Log::displayInfo "Using ${VENDOR}:${BASH_TAR_VERSION}"

if [[ "${SKIP_BUILD:-0}" = "0" && -f "${FRAMEWORK_ROOT_DIR}/.docker/DockerfileUser" ]]; then
  "${FRAMEWORK_BIN_DIR}/buildPushDockerImages" "${VENDOR}" "${BASH_TAR_VERSION}" "${BASH_IMAGE}"

  # build docker image with user configuration
  # shellcheck disable=SC2086
  DOCKER_BUILDKIT=1 docker build \
    ${DOCKER_BUILD_OPTIONS} \
    --cache-from "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}" \
    --build-arg "BASH_IMAGE=bash-tools-${VENDOR}-${BASH_TAR_VERSION}:latest" \
    --build-arg SKIP_USER="${SKIP_USER:-0}" \
    --build-arg USER_ID="${USER_ID:-$(id -u)}" \
    --build-arg GROUP_ID="${GROUP_ID:-$(id -g)}" \
    -f "${FRAMEWORK_ROOT_DIR}/.docker/DockerfileUser" \
    -t "bash-tools-${VENDOR}-${BASH_TAR_VERSION}-user" \
    "${FRAMEWORK_ROOT_DIR}/.docker"
fi

# run tests
args=(-e KEEP_TEMP_FILES="${KEEP_TEMP_FILES}")
if tty -s; then
  args+=("-it")
fi

if [[ -d "$(pwd)/vendor/bash-tools-framework" ]]; then
  args+=(-v "$(cd "$(pwd)/vendor/bash-tools-framework" && pwd -P):/bash/vendor/bash-tools-framework")
fi
(
  set -x
  # shellcheck disable=SC2086
  docker run \
    --rm \
    ${DOCKER_RUN_OPTIONS} \
    "${args[@]}" \
    -w /bash \
    -v "$(pwd):/bash" \
    -v "/tmp:/tmp" \
    --user "${USER_ID:-$(id -u)}:${GROUP_ID:-$(id -g)}" \
    "bash-tools-${VENDOR}-${BASH_TAR_VERSION}-user" \
    "$@"
)
