#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/test
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
    # shellcheck disable=SC2034
    local -a dockerRunCmd=(
      "/bash/bin/test"
      "${batsArgs[@]}"
    )
    # shellcheck disable=SC2034
    local -a dockerRunArgs
    if [[ "$0" =~ ^/ ]]; then
      dockerRunArgs+=(
        -v "$0:/bash/bin/test"
      )
    else
      dockerRunArgs+=(
        -v "$(pwd -P)/$0:/bash/bin/test"
      )
    fi

    # shellcheck disable=SC2154
    Docker::runBuildContainer \
      "${optionVendor}" \
      "${optionBashVersion}" \
      "${optionBashBaseImage}" \
      "${optionSkipDockerBuild}" \
      "${optionTraceVerbose}" \
      "${optionContinuousIntegrationMode}" \
      dockerRunCmd \
      dockerRunArgs
  fi
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
