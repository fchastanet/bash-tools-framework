#!/usr/bin/env bash

# shellcheck disable=SC2034
declare MIN_HADOLINT_VERSION="2.12.0"

optionHelpCallback() {
  local hadolintHelpFile
  hadolintHelpFile="$(Framework::createTempFile "hadolintHelp")"
  "${FRAMEWORK_VENDOR_BIN_DIR}/hadolint" --help >"${hadolintHelpFile}"

  dockerLintCommandHelp help |
    sed -E \
      -e "/@@@HADOLINT_HELP@@@/r ${hadolintHelpFile}" \
      -e "/@@@HADOLINT_HELP@@@/d"
  exit 0
}

optionVersionCallback() {
  echo -e "${__HELP_TITLE_COLOR}${SCRIPT_NAME} version: ${__RESET_COLOR}{{ .RootData.binData.commands.default.version }}"
  echo -e -n "${__HELP_TITLE_COLOR}hadolint Version: ${__RESET_COLOR}"
  "${FRAMEWORK_VENDOR_BIN_DIR}/hadolint" --version
  exit 0
}

unknownOption() {
  BASH_FRAMEWORK_ARGV_FILTERED+=("$1")
}

declare -a BASH_FRAMEWORK_ARGV_ONLY_ARG=()
unknownArg() {
  if [[ -f "$1" ]]; then
    BASH_FRAMEWORK_ARGV_ONLY_ARG+=("$1")
  else
    BASH_FRAMEWORK_ARGV_FILTERED+=("$1")
  fi
}
