#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/runBuildContainer

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"

HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} run the container specified by args provided.
Command to run is passed via the rest of arguments
TTY allocation is detected automatically

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} <vendor> <bash_tar_version> <bash_base_image> <bash_image> ...
additional docker build options can be passed via DOCKER_BUILD_OPTIONS env variable

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"
Args::defaultHelp "${HELP}" "$@" || true

VENDOR="${VENDOR:-ubuntu}"
BASH_TAR_VERSION="${BASH_TAR_VERSION:-5.1}"
BASH_IMAGE="${BASH_IMAGE:-ubuntu:20.04}"
DOCKER_BUILD_OPTIONS="${DOCKER_BUILD_OPTIONS:-}"

Log::displayInfo "Using ${VENDOR}:${BASH_TAR_VERSION}"

if [[ "${SKIP_BUILD:-0}" = "0" && -f "${FRAMEWORK_DIR:-${ROOT_DIR}}/.docker/DockerfileUser" ]]; then
  "${BIN_DIR}/buildPushDockerImages" "${VENDOR}" "${BASH_TAR_VERSION}" "${BASH_IMAGE}"

  # build docker image with user configuration
  # shellcheck disable=SC2086
  DOCKER_BUILDKIT=1 docker build \
    ${DOCKER_BUILD_OPTIONS} \
    --cache-from "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}" \
    --build-arg "BASH_IMAGE=bash-tools-${VENDOR}-${BASH_TAR_VERSION}:latest" \
    --build-arg SKIP_USER="${SKIP_USER:-0}" \
    --build-arg USER_ID="${USER_ID:-$(id -u)}" \
    --build-arg GROUP_ID="${GROUP_ID:-$(id -g)}" \
    -f "${FRAMEWORK_DIR:-${ROOT_DIR}}/.docker/DockerfileUser" \
    -t "bash-tools-${VENDOR}-${BASH_TAR_VERSION}-user" \
    "${FRAMEWORK_DIR:-${ROOT_DIR}}/.docker"
fi

# run tests
args=()
if tty -s; then
  args+=("-it")
fi

if [[ -d "$(pwd)/vendor/bash-tools-framework" ]]; then
  args+=(-v "$(cd "$(pwd)/vendor/bash-tools-framework" && pwd -P):/bash/vendor/bash-tools-framework")
fi

(
  set -x
  docker run \
    --rm \
    "${args[@]}" \
    -w /bash \
    -v "$(pwd):/bash" \
    --user "${USER_ID:-$(id -u)}:${GROUP_ID:-$(id -g)}" \
    "bash-tools-${VENDOR}-${BASH_TAR_VERSION}-user" \
    "$@"
)
