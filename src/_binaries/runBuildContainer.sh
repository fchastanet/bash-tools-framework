#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/runBuildContainer
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "${TEMPLATE_DIR}/_includes/_header.tpl"

HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} run the container specified by args provided.
Command to run is passed via the rest of arguments
TTY allocation is detected automatically

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} <vendor> <bash_tar_version> <bash_base_image> <bash_image> ...
additional docker build options can be passed via DOCKER_BUILD_OPTIONS env variable
EOF
)"
Args::defaultHelp "${HELP}" "$@" || true

VENDOR="${VENDOR:-ubuntu}"
BASH_TAR_VERSION="${BASH_TAR_VERSION:-5.1}"
BASH_IMAGE="${BASH_IMAGE:-ubuntu:20.04}"
DOCKER_BUILD_OPTIONS="${DOCKER_BUILD_OPTIONS:-}"

Log::displayInfo "Using ${VENDOR}:${BASH_TAR_VERSION}"

if [[ ! -d "${ROOT_DIR}/vendor" ]]; then
  "${BIN_DIR}/installDevRequirements"
fi

if [[ "${SKIP_BUILD:-0}" = "0" && -f "${ROOT_DIR}/.docker/DockerfileUser" ]]; then
  "${BIN_DIR}/buildPushDockerImages" "${VENDOR}" "${BASH_TAR_VERSION}" "${BASH_IMAGE}"

  # build docker image with user configuration
  # shellcheck disable=SC2086
  DOCKER_BUILDKIT=1 docker build \
    ${DOCKER_BUILD_OPTIONS} \
    --cache-from "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}" \
    --build-arg "BASH_IMAGE=bash-tools-${VENDOR}-${BASH_TAR_VERSION}:latest" \
    --build-arg SKIP_USER="${SKIP_USER:-0}" \
    --build-arg USER_ID="$(id -u)" \
    --build-arg GROUP_ID="$(id -g)" \
    -f "${ROOT_DIR}/.docker/DockerfileUser" \
    -t "bash-tools-${VENDOR}-${BASH_TAR_VERSION}-user" \
    "${ROOT_DIR}/.docker"
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
  -v "$(pwd):/bash" \
  --user "$(id -u):$(id -g)" \
  "bash-tools-${VENDOR}-${BASH_TAR_VERSION}-user" \
  "$@"
