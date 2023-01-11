#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/test
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"

Bats::installRequirementsIfNeeded

HELP="$(
  cat <<EOF
${__HELP_TITLE}Usage:${__HELP_NORMAL} ${SCRIPT_NAME}
Launch bats inside docker container

${__HELP_TITLE}Examples:${__HELP_NORMAL}
to force image rebuilding
    DOCKER_BUILD_OPTIONS=--no-cache ./bin/test

rebuild alpine image
    DOCKER_BUILD_OPTIONS=--no-cache VENDOR=alpine BASH_IMAGE=bash:5.1 BASH_TAR_VERSION=5.1 ./bin/test

${__HELP_TITLE}In order to debug inside container:${__HELP_NORMAL}
    docker build -t bash-tools-ubuntu:5.1 -f .docker/Dockerfile.ubuntu
    docker run --rm -it -v "$(pwd):/bash"  --user "$(id -u):$(id -g)"  bash-tools-ubuntu-5.1-user bash
    docker run --rm -it -v "$(pwd):/bash"  --user "$(id -u):$(id -g)"  bash-tools-alpine-5.1-user bash

${__HELP_TITLE}Bats help:${__HELP_NORMAL}

.INCLUDE "$(dynamicTemplateDir _includes/author.tpl)"

EOF
)"
if ! Args::defaultHelpNoExit "${HELP}" "$@"; then
  "${VENDOR_DIR}/bats/bin/bats" --help
  exit 0
fi

if [[ "${IN_BASH_DOCKER:-}" = "You're in docker" ]]; then
  (
    if (($# < 1)); then
      "${VENDOR_DIR}/bats/bin/bats" -r tests
    else
      "${VENDOR_DIR}/bats/bin/bats" "$@"
    fi
  )
else
  "${BIN_DIR}/runBuildContainer" "/bash/bin/test" "$@"
fi
