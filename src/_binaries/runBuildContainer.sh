#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/runBuildContainer
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options/command.runBuildContainer.tpl)"

declare -a dockerRunCmd=()
declare -a dockerRunArgs=()
declare -a dockerRunArgs=(
  -e KEEP_TEMP_FILES="${KEEP_TEMP_FILES}"
  -e BATS_FIX_TEST="${BATS_FIX_TEST:-0}"
)
export DOCKER_BUILD_OPTIONS="${DOCKER_BUILD_OPTIONS:-}"
export DOCKER_RUN_OPTIONS="${DOCKER_RUN_OPTIONS:-}"
export BASH_FRAMEWORK_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"

runBuildContainerCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

run() {
  Docker::runBuildContainer
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
