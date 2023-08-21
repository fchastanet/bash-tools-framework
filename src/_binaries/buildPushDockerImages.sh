#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/buildPushDockerImages
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

HELP="$(
  cat <<EOF
${__HELP_TITLE}Description:${__HELP_NORMAL} pull, build and push docker image
- pull previous docker image from docker hub if exists
- build new image using previous image as cache
- tag built image
- push it to docker registry

${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME} <vendor> <bash_tar_version> <bash_base_image> <branch_name> <push_image>
additional docker build options can be passed via DOCKER_BUILD_OPTIONS env variable

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"
EOF
)"
Args::defaultHelp "${HELP}" "${BASH_FRAMEWORK_ARGV[@]}" || true

VENDOR="$1"
BASH_TAR_VERSION="$2"
BASH_BASE_IMAGE="$3"
BRANCH_NAME="$4"
PUSH_IMAGE="${5:-}"
DOCKER_BUILD_OPTIONS="${DOCKER_BUILD_OPTIONS:-}"

if [[ -z "${VENDOR}" || -z "${BASH_TAR_VERSION}" || -z "${BASH_BASE_IMAGE}" ]]; then
  Log::fatal "please provide these parameters VENDOR, BASH_TAR_VERSION, BASH_BASE_IMAGE"
fi

# pull image if needed
if [[ "${BRANCH_NAME}" != 'refs/heads/master' ]]; then
  docker pull "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}" || true
fi

# build image and push it ot registry
# shellcheck disable=SC2086
DOCKER_BUILDKIT=1 docker build \
  ${DOCKER_BUILD_OPTIONS} \
  -f "${BASH_TOOLS_ROOT_DIR:-${FRAMEWORK_ROOT_DIR}}/.docker/Dockerfile.${VENDOR}" \
  --cache-from "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}" \
  --build-arg BUILDKIT_INLINE_CACHE=1 \
  --build-arg BASH_TAR_VERSION="${BASH_TAR_VERSION}" \
  --build-arg BASH_IMAGE="${BASH_BASE_IMAGE}" \
  -t "bash-tools-${VENDOR}-${BASH_TAR_VERSION}" \
  -t "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}" \
  "${BASH_TOOLS_ROOT_DIR:-${FRAMEWORK_ROOT_DIR}}/.docker"
docker run --rm "bash-tools-${VENDOR}-${BASH_TAR_VERSION}" bash --version

if [[ "${PUSH_IMAGE}" == "push" ]]; then
  docker push "scrasnups/build:bash-tools-${VENDOR}-${BASH_TAR_VERSION}"
fi
