#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/buildPushDockerImage
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options/command.buildPushDockerImage.tpl)"

buildPushDockerImageCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

run() {
  # shellcheck disable=SC2154
  Docker::buildPushDockerImage \
    "${optionVendor}" \
    "${optionBashVersion}" \
    "${optionBashBaseImage}" \
    "${optionPush}" \
    "${optionTraceVerbose}"
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
