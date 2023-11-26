#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/test
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

Bats::installRequirementsIfNeeded "${FRAMEWORK_ROOT_DIR}"

.INCLUDE "$(dynamicTemplateDir _binaries/options/command.test.tpl)"

testCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

# shellcheck disable=SC2154
run() {
  if [[ "${IN_BASH_DOCKER:-}" = "You're in docker" ]]; then
    (
      "${FRAMEWORK_VENDOR_DIR}/bats/bin/bats" "${batsArgs[@]}"
    )
  else
    "${COMMAND_BIN_DIR}/runBuildContainer" "/bash/bin/test" "${batsArgs[@]}"
  fi
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
