#!/usr/bin/env bash
# BIN_FILE=${FRAMEWORK_ROOT_DIR}/bin/definitionLint
# VAR_RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR=..
# FACADE

.INCLUDE "$(dynamicTemplateDir _binaries/options.definitionLint.tpl)"

declare optionFormat="plain"
definitionLintCommand parse "${BASH_FRAMEWORK_ARGV[@]}"

# build image and push it ot registry
run() {
  # shellcheck disable=SC2154
  Profiles::lintDefinitions "${argFolder}" "${optionFormat}"
}

if [[ "${BASH_FRAMEWORK_QUIET_MODE:-0}" = "1" ]]; then
  run &>/dev/null
else
  run
fi
