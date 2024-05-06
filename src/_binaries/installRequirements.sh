#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/installRequirements
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE
# shellcheck disable=SC2034,SC2154

declare copyrightBeginYear="2024"
declare optionBashFrameworkConfig="${FRAMEWORK_ROOT_DIR}/.framework-config"

.INCLUDE "$(dynamicTemplateDir _binaries/installRequirements.options.tpl)"

# @require Linux::requireExecutedAsUser
run() {
  mkdir -p "${FRAMEWORK_ROOT_DIR}/vendor" || true
  Bats::installRequirementsIfNeeded "${FRAMEWORK_ROOT_DIR}"
  Softwares::installHadolint
  Softwares::installShellcheck
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
