#!/usr/bin/env bash

declare -a BASH_FRAMEWORK_ARGV_FILTERED=()

beforeParseCallback() {
  Env::requireLoad
  UI::requireTheme
  Log::requireLoad
}

copyrightCallback() {
  #{{- $copyrightBeginYear := .RootData.binData.commands.default.copyrightBeginYear | default "$(date +%Y)" }}
  # shellcheck disable=SC2155,SC2154,SC2250
  echo "Copyright (c) {{ $copyrightBeginYear }}-now François Chastanet"
}

# shellcheck disable=SC2317 # if function is overridden
updateArgListInfoVerboseCallback() {
  BASH_FRAMEWORK_ARGV_FILTERED+=(--verbose)
}
# shellcheck disable=SC2317 # if function is overridden
updateArgListDebugVerboseCallback() {
  BASH_FRAMEWORK_ARGV_FILTERED+=(-vv)
}
# shellcheck disable=SC2317 # if function is overridden
updateArgListTraceVerboseCallback() {
  BASH_FRAMEWORK_ARGV_FILTERED+=(-vvv)
}
# shellcheck disable=SC2317 # if function is overridden
updateArgListEnvFileCallback() { :; }
# shellcheck disable=SC2317 # if function is overridden
updateArgListLogLevelCallback() { :; }
# shellcheck disable=SC2317 # if function is overridden
updateArgListDisplayLevelCallback() { :; }
# shellcheck disable=SC2317 # if function is overridden
updateArgListNoColorCallback() {
  BASH_FRAMEWORK_ARGV_FILTERED+=(--no-color)
}
# shellcheck disable=SC2317 # if function is overridden
updateArgListThemeCallback() { :; }
# shellcheck disable=SC2317 # if function is overridden
updateArgListQuietCallback() { :; }

# shellcheck disable=SC2317 # if function is overridden
optionHelpCallback() {
  Log::displayError "optionHelpCallback needs to be overridden"
  exit 0
}

# shellcheck disable=SC2317 # if function is overridden
optionVersionCallback() {
  # shellcheck disable=SC2154
  echo "${SCRIPT_NAME} version {{ .RootData.binData.commands.default.version }}"
  exit 0
}

# shellcheck disable=SC2317 # if function is overridden
optionInfoVerboseCallback() {
  BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='--verbose'
  BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_INFO}
  echo "BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_INFO}" >>"${overrideEnvFile}"
}

# shellcheck disable=SC2317 # if function is overridden
optionDebugVerboseCallback() {
  BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='-vv'
  BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_DEBUG}
  echo "BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_DEBUG}" >>"${overrideEnvFile}"
}

# shellcheck disable=SC2317 # if function is overridden
optionTraceVerboseCallback() {
  # shellcheck disable=SC2034
  BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='-vvv'
  BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_TRACE}
  echo "BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_DEBUG}" >>"${overrideEnvFile}"
}

getLevel() {
  local levelName="$1"
  case "${levelName^^}" in
    OFF)
      echo "${__LEVEL_OFF}"
      ;;
    ERR | ERROR)
      echo "${__LEVEL_ERROR}"
      ;;
    WARN | WARNING)
      echo "${__LEVEL_WARNING}"
      ;;
    INFO)
      echo "${__LEVEL_INFO}"
      ;;
    DEBUG | TRACE)
      echo "${__LEVEL_DEBUG}"
      ;;
    *)
      Log::displayError "Command ${SCRIPT_NAME} - Invalid level ${levelName}"
      return 1
      ;;
  esac
}

getLevelText() {
  local level="$1"
  case "${level}" in
    "${__LEVEL_OFF}")
      echo OFF
      ;;
    "${__LEVEL_ERROR}")
      echo ERROR
      ;;
    "${__LEVEL_WARNING}")
      echo WARNING
      ;;
    "${__LEVEL_INFO}")
      echo INFO
      ;;
    "${__LEVEL_DEBUG}")
      echo DEBUG
      ;;
    *)
      Log::displayError "Command ${SCRIPT_NAME} - Invalid level ${level}"
      return 1
      ;;
  esac
}

getVerboseLevel() {
  local levelName="$1"
  case "${levelName^^}" in
    OFF)
      echo "${__VERBOSE_LEVEL_OFF}"
      ;;
    ERR | ERROR | WARN | WARNING | INFO)
      echo "${__VERBOSE_LEVEL_INFO}"
      ;;
    DEBUG)
      echo "${__VERBOSE_LEVEL_DEBUG}"
      ;;
    TRACE)
      echo "${__VERBOSE_LEVEL_TRACE}"
      ;;
    *)
      Log::displayError "Command ${SCRIPT_NAME} - Invalid level ${level}"
      return 1
      ;;
  esac
}

# shellcheck disable=SC2317 # if function is overridden
optionDisplayLevelCallback() {
  local level="$2"
  local logLevel verboseLevel
  logLevel="$(getLevel "${level}")"
  verboseLevel="$(getVerboseLevel "${level}")"
  BASH_FRAMEWORK_ARGS_VERBOSE=${verboseLevel}
  echo "BASH_FRAMEWORK_DISPLAY_LEVEL=${logLevel}" >>"${overrideEnvFile}"
}

optionDisplayLevelDefaultValueFunction() {
  getLevelText "${BASH_FRAMEWORK_DISPLAY_LEVEL:-${__LEVEL_INFO}}"
}

# shellcheck disable=SC2317 # if function is overridden
optionLogLevelCallback() {
  local level="$2"
  local logLevel verboseLevel
  logLevel="$(getLevel "${level}")"
  verboseLevel="$(getVerboseLevel "${level}")"
  # shellcheck disable=SC2034
  BASH_FRAMEWORK_ARGS_VERBOSE=${verboseLevel}
  echo "BASH_FRAMEWORK_LOG_LEVEL=${logLevel}" >>"${overrideEnvFile}"
}

optionLogLevelDefaultValueFunction() {
  getLevelText "${BASH_FRAMEWORK_LOG_LEVEL:-${__LEVEL_OFF}}"
}

# shellcheck disable=SC2317 # if function is overridden
optionLogFileCallback() {
  local logFile="$2"
  echo "BASH_FRAMEWORK_LOG_FILE='${logFile}'" >>"${overrideEnvFile}"
}

optionLogFileDefaultValueFunction() {
  # shellcheck disable=SC2016
  echo "${BASH_FRAMEWORK_LOG_FILE:-"${FRAMEWORK_ROOT_DIR}/logs/${SCRIPT_NAME}.log"}"
}

# shellcheck disable=SC2317 # if function is overridden
optionQuietCallback() {
  echo "BASH_FRAMEWORK_QUIET_MODE=1" >>"${overrideEnvFile}"
}

# shellcheck disable=SC2317 # if function is overridden
optionNoColorCallback() {
  UI::theme "noColor"
}

# shellcheck disable=SC2317 # if function is overridden
optionThemeCallback() {
  UI::theme "$2"
}

displayConfig() {
  echo "Config"
  UI::drawLine "-"
  local var
  while read -r var; do
    printf '%-40s = %s\n' "${var}" "$(declare -p "${var}" | sed -E -e 's/^[^=]+=(.*)/\1/')"
  done < <(typeset -p | awk 'match($3, "^(BASH_FRAMEWORK_[^=]+)=", m) { print m[1] }' | sort)
  exit 0
}

optionBashFrameworkConfigCallback() {
  if [[ ! -f "$2" ]]; then
    Log::fatal "Command ${SCRIPT_NAME} - Bash framework config file '$2' does not exists"
  fi
}

overrideEnvFile="$(Framework::createTempFile "overrideEnvFile")"

commandOptionParseFinished() {
  # shellcheck disable=SC2154
  if [[ -f "${optionBashFrameworkConfig}" ]]; then
    files+=("${optionBashFrameworkConfig}")
  fi
  files+=("${overrideEnvFile}")
  Env::requireLoad "${files[@]}"
  Log::requireLoad
  # shellcheck disable=SC2154
  if [[ "${optionConfig}" = "1" ]]; then
    displayConfig
  fi
}
