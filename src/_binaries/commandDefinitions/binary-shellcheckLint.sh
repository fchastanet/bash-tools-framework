#!/usr/bin/env bash
declare MIN_SHELLCHECK_VERSION="0.9.0"
declare versionNumber="1.0"
declare commandFunctionName="shellcheckLintCommand"
declare help="Lint bash files using shellcheck."
declare optionFormatDefault="tty"

declare copyrightBeginYear="2022"
declare optionFormat="${optionFormatDefault}"
declare -a shellcheckArgs=()
declare -a shellcheckFiles=()

beforeParseCallback() {
  Env::requireLoad
  UI::requireTheme
  Log::requireLoad
  Compiler::Facade::requireCommandBinDir
}
unknownOption() {
  shellcheckArgs+=("$1")
}
argShellcheckFilesCallback() {
  if [[ -f "$1" ]]; then
    shellcheckFiles=("${@::$#-1}")
  else
    shellcheckArgs+=("$1")
  fi
}
shellcheckLintParseCallback() {
  if [[ "${optionStaged}" = "1" ]] && ((${#argShellcheckFiles[@]} > 0)); then
    Log::displayWarning "${SCRIPT_NAME} - --staged option ignored as files have been provided"
    optionStaged="0"
  fi
  shellcheckArgs=(-f "${optionFormat}")
}

optionHelpCallback() {
  local shellcheckHelpFile
  shellcheckHelpFile="$(Framework::createTempFile "shellcheckHelp")"
  (
    if [[ -x "${FRAMEWORK_VENDOR_BIN_DIR}/shellcheck" ]]; then
      "${FRAMEWORK_VENDOR_BIN_DIR}/shellcheck" --help
    else
      Log::displayError "${FRAMEWORK_VENDOR_BIN_DIR}/shellcheck does not exist" 2>&1
    fi
  ) >"${shellcheckHelpFile}" 2>&1

  shellcheckLintCommandHelp |
    sed -E \
      -e "/@@@SHELLCHECK_HELP@@@/r ${shellcheckHelpFile}" \
      -e "/@@@SHELLCHECK_HELP@@@/d"
  exit 0
}

optionVersionCallback() {
  echo -e "${__HELP_TITLE_COLOR}${SCRIPT_NAME} version: ${__RESET_COLOR} ${versionNumber}"
  echo -e -n "${__HELP_TITLE_COLOR}shellcheck Version: ${__RESET_COLOR}"
  "${FRAMEWORK_VENDOR_BIN_DIR}/shellcheck" --version
  exit 0
}
