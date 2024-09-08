#!/usr/bin/env bash

# shellcheck disable=SC2034
declare -a megalinterArgs=()

optionHelpCallback() {
  megalinterCommandHelp
  exit 0
}

unknownArg() {
  if [[ -f "$1" ]]; then
    megalinterArgs+=("$1")
  else
    Log::displayError "Command ${SCRIPT_NAME} - unknown file '$1'"
    return 1
  fi
}

filesOnlyCallback() {
  megalinterOptions+=(-e SKIP_CLI_LINT_MODES=project)
}

checkMegalinterVersionAndExit() {
  local newVersion
  Github::getLatestRelease "oxsecurity/megalinter" newVersion
  newVersion="$(Version::parse <<<"${newVersion}")"
  local currentVersion
  # shellcheck disable=SC2154
  currentVersion="$(Version::parse <<<"${optionMegalinterImage}")"
  local status=0
  Version::compare "${currentVersion}" "${newVersion}" || status=$?
  case ${status} in
    1)
      echo -e "${__ERROR_COLOR}version ${currentVersion} is greater than ${newVersion}${__RESET_COLOR}"
      exit 2
      ;;
    2)
      echo -e "${__WARNING_COLOR}new version ${newVersion} is available, your version is ${currentVersion}${__RESET_COLOR}"
      exit 1
      ;;
    *)
      echo -e "${__INFO_COLOR}no new version available${__RESET_COLOR}"
      ;;
  esac
  exit 0
}

commandCallback() {
  Linux::requireJqCommand
  # shellcheck disable=SC2154
  if [[ "${optionCheckMegalinterVersion}" = "1" ]]; then
    checkMegalinterVersionAndExit
  fi
  # shellcheck disable=SC2154
  if [[ "${optionIncremental}" = "1" ]] && ((${#megalinterArgs[@]} > 0)); then
    Log::fatal "you cannot provide a list of files and the --incremental option"
  fi
  if ((${#megalinterArgs[@]} > 0)); then
    megalinterOptions+=(
      -e MEGALINTER_FILES_TO_LINT="$(Array::join "," "${megalinterArgs[@]}")"
    )
  fi
}

optionFixCallback() {
  megalinterOptions+=(-e APPLY_FIXES=all)
}

optionVersionCallback() {
  echo -e "${__HELP_TITLE_COLOR}${SCRIPT_NAME} version:${__RESET_COLOR} {{ .RootData.binData.commands.default.version }}"
  echo -e "${__HELP_TITLE_COLOR}megalinter image Version:${__RESET_COLOR} ${optionMegalinterImage}"
  exit 0
}

getMegalinterLevel() {
  local levelName="$1"
  case "${levelName^^}" in
    OFF) return 1 ;;
    DEBUG | TRACE) echo "debug" ;;
    INFO) echo "info" ;;
    WARNING) echo "warning" ;;
    ERROR) echo "error" ;;
    *)
      # ignore
      return 1
      ;;
  esac
}

updateArgListLogLevelCallback() {
  local level="$2"
  local megalinterLevel
  megalinterLevel="$(getMegalinterLevel "${level}")" || return 0
  megalinterOptions+=(-e "LOG_LEVEL=${megalinterLevel}")
}
updateArgListInfoVerboseCallback() {
  updateArgListLogLevelCallback "$1" "warning"
}
updateArgListDebugVerboseCallback() {
  updateArgListLogLevelCallback "$1" "info"
}
updateArgListTraceVerboseCallback() {
  updateArgListLogLevelCallback "$1" "debug"
}
