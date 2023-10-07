%# Needed variables
%# - versionNumber
%# - commandFunctionName
%# - SCRIPT_NAME
%# - help
%# - longDescription
%
  # shellcheck source=/dev/null
  source <(
    Options::generateGroup \
      --title "GLOBAL OPTIONS:" \
      --function-name groupGlobalOptionsFunction

    Options::generateOption \
      --help "Display this command help" \
      --group groupGlobalOptionsFunction \
      --alt "--help" \
      --alt "-h" \
      --callback optionHelpCallback \
      --variable-name "optionHelp" \
      --function-name optionHelpFunction

    Options::generateOption \
      --help "Display configuration" \
      --group groupGlobalOptionsFunction \
      --alt "--config" \
      --variable-name "optionConfig" \
      --function-name optionConfigFunction

    Options::generateOption \
      --variable-type String \
      --help "use alternate bash framework configuration." \
      --group groupGlobalOptionsFunction \
      --alt "--bash-framework-config" \
      --callback optionBashFrameworkConfigCallback \
      --variable-name "optionBashFrameworkConfig" \
      --function-name optionBashFrameworkConfigFunction

    Options::generateOption \
      --help "info level verbose mode (alias of --display-level INFO)" \
      --group groupGlobalOptionsFunction \
      --alt "--verbose" --alt "-v" \
      --callback optionInfoVerboseCallback \
      --callback updateArgListInfoVerboseCallback \
      --variable-name "optionInfoVerbose" \
      --function-name optionInfoVerboseFunction

    Options::generateOption \
      --help "debug level verbose mode (alias of --display-level DEBUG)" \
      --group groupGlobalOptionsFunction \
      --alt "-vv" \
      --callback optionDebugVerboseCallback \
      --callback updateArgListDebugVerboseCallback \
      --variable-name "optionDebugVerbose" \
      --function-name optionDebugVerboseFunction

    Options::generateOption \
      --help "trace level verbose mode (alias of --display-level TRACE)" \
      --group groupGlobalOptionsFunction \
      --alt "-vvv" \
      --callback optionTraceVerboseCallback \
      --callback updateArgListTraceVerboseCallback \
      --variable-name "optionTraceVerbose" \
      --function-name optionTraceVerboseFunction

    Options::generateOption \
      --variable-type StringArray \
      --help "Load the specified env file" \
      --group groupGlobalOptionsFunction \
      --alt "--env-file" \
      --max -1 \
      --callback optionEnvFileCallback \
      --callback updateArgListEnvFileCallback \
      --variable-name "optionEnvFiles" \
      --function-name optionEnvFilesFunction

    Options::generateOption \
      --variable-type String \
      --help "Set log level (one of OFF, ERROR, WARNING, INFO, DEBUG, TRACE value)" \
      --group groupGlobalOptionsFunction \
      --alt "--log-level" \
      --authorized-values "OFF|ERROR|WARNING|INFO|DEBUG|TRACE" \
      --callback "optionLogLevelCallback" \
      --callback updateArgListLogLevelCallback \
      --variable-name "optionLogLevel" \
      --function-name optionLogLevelFunction

    Options::generateOption \
      --variable-type String \
      --help "Set log file" \
      --group groupGlobalOptionsFunction \
      --alt "--log-file" \
      --callback "optionLogFileCallback" \
      --callback updateArgListLogFileCallback \
      --variable-name "optionLogFile" \
      --function-name optionLogFileFunction

    Options::generateOption \
      --variable-type String \
      --help "set display level (one of OFF, ERROR, WARNING, INFO, DEBUG, TRACE value)" \
      --group groupGlobalOptionsFunction \
      --alt "--display-level" \
      --authorized-values "OFF|ERROR|WARNING|INFO|DEBUG|TRACE" \
      --callback optionDisplayLevelCallback \
      --callback updateArgListDisplayLevelCallback \
      --variable-name "optionDisplayLevel" \
      --function-name optionDisplayLevelFunction

    Options::generateOption \
      --help "Produce monochrome output. alias of --theme noColor." \
      --group groupGlobalOptionsFunction \
      --alt "--no-color" \
      --callback optionNoColorCallback \
      --callback updateArgListNoColorCallback \
      --variable-name "optionNoColor" \
      --function-name optionNoColorFunction

    Options::generateOption \
      --variable-type String \
      --help "$(echo "choose color theme (default, default-force or noColor) -" \
          "default-force means colors will be produced even if command is piped")" \
      --group groupGlobalOptionsFunction \
      --alt "--theme" \
      --authorized-values "default|default-force|noColor" \
      --callback optionThemeCallback \
      --callback updateArgListThemeCallback \
      --variable-name "optionTheme" \
      --function-name optionThemeFunction

    Options::generateOption \
      --help "Print version information and quit" \
      --group groupGlobalOptionsFunction \
      --alt "--version" \
      --callback optionVersionCallback \
      --variable-name "optionVersion" \
      --function-name optionVersionFunction

    Options::generateOption \
      --help "quiet mode, doesn't display any output" \
      --group groupGlobalOptionsFunction \
      --alt "--quiet" --alt "-q" \
      --callback optionQuietCallback \
      --callback updateArgListQuietCallback \
      --variable-name "optionQuiet" \
      --function-name optionQuietFunction
  )

  declare -a options=(
    --author "[François Chastanet](https://github.com/fchastanet)"
    --source-file "${REPOSITORY_URL}/tree/master/${SRC_FILE_PATH}"
    --license "MIT License"
    --copyright "Copyright (c) 2023 François Chastanet"
    --version "${versionNumber}"
    --function-name "${commandFunctionName}"
    --command-name "${SCRIPT_NAME}"
    --callback commandOptionParseFinished
    --help "${help}"
    --long-description """${longDescription}"""
    optionBashFrameworkConfigFunction
    optionConfigFunction
    optionNoColorFunction
    optionThemeFunction
    optionHelpFunction
    optionVersionFunction
    optionQuietFunction
    optionLogLevelFunction
    optionLogFileFunction
    optionDisplayLevelFunction
    optionInfoVerboseFunction
    optionDebugVerboseFunction
    optionTraceVerboseFunction
    optionEnvFilesFunction
  )
%

%# default add option callbacks
declare -a BASH_FRAMEWORK_ARGV_FILTERED=()
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
  <% ${commandFunctionName} %> help
  exit 0
}

# shellcheck disable=SC2317 # if function is overridden
optionVersionCallback() {
  echo "${SCRIPT_NAME} version <% ${versionNumber} %>"
  exit 0
}

# shellcheck disable=SC2317 # if function is overridden
optionEnvFileCallback() {
  local envFile="$2"
  if [[ ! -f "${envFile}" || ! -r "${envFile}" ]]; then
    Log::displayError "Command ${SCRIPT_NAME} - Option --env-file - File '${envFile}' doesn't exist"
    exit 1
  fi
}

# shellcheck disable=SC2317 # if function is overridden
optionInfoVerboseCallback() {
  BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='--verbose'
  BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_INFO}
  BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_INFO}
}

# shellcheck disable=SC2317 # if function is overridden
optionDebugVerboseCallback() {
  BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='-vv'
  BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_DEBUG}
  BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_DEBUG}
}

# shellcheck disable=SC2317 # if function is overridden
optionTraceVerboseCallback() {
  BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='-vvv'
  BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_TRACE}
  BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_DEBUG}
}

getLevel() {
  local levelName="$1"
  case "${levelName^^}" in
    OFF)
      echo "${__LEVEL_OFF}"
      ;;
    ERROR)
      echo "${__LEVEL_ERROR}"
      ;;
    WARNING)
      echo "${__LEVEL_WARNING}"
      ;;
    INFO)
      echo "${__LEVEL_INFO}"
      ;;
    DEBUG | TRACE)
      echo "${__LEVEL_DEBUG}"
      ;;
    *)
      Log::displayError "Command ${SCRIPT_NAME} - Invalid level ${level}"
      return 1
  esac
}

getVerboseLevel() {
  local levelName="$1"
  case "${levelName^^}" in
    OFF)
      echo "${__VERBOSE_LEVEL_OFF}"
      ;;
    ERROR | WARNING | INFO)
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
  esac
}

# shellcheck disable=SC2317 # if function is overridden
optionDisplayLevelCallback() {
  local level="$2"
  local logLevel verboseLevel
  logLevel="$(getLevel "${level}")"
  verboseLevel="$(getVerboseLevel "${level}")"
  BASH_FRAMEWORK_ARGS_VERBOSE=${verboseLevel}
  BASH_FRAMEWORK_DISPLAY_LEVEL=${logLevel}
}

# shellcheck disable=SC2317 # if function is overridden
optionLogLevelCallback() {
  local level="$2"
  local logLevel verboseLevel
  logLevel="$(getLevel "${level}")"
  verboseLevel="$(getVerboseLevel "${level}")"
  BASH_FRAMEWORK_ARGS_VERBOSE=${verboseLevel}
  BASH_FRAMEWORK_LOG_LEVEL=${logLevel}
}

# shellcheck disable=SC2317 # if function is overridden
optionLogFileCallback() {
  local logFile="$2"
  BASH_FRAMEWORK_LOG_FILE="${logFile}"
}

# shellcheck disable=SC2317 # if function is overridden
optionQuietCallback() {
  BASH_FRAMEWORK_QUIET_MODE=1
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

commandOptionParseFinished() {
  if [[ -z "${BASH_FRAMEWORK_ENV_FILES[0]+1}" ]]; then
    BASH_FRAMEWORK_ENV_FILES=()
  fi
  BASH_FRAMEWORK_ENV_FILES+=("${optionEnvFiles[@]}")
  export BASH_FRAMEWORK_ENV_FILES
  Env::requireLoad
  Log::requireLoad

  # load .framework-config
  if [[ -n "${optionBashFrameworkConfig}" && -f "${optionBashFrameworkConfig}" ]]; then
    BASH_FRAMEWORK_CONFIG_FILE="${optionBashFrameworkConfig}"
    # shellcheck source=/.framework-config
    source "${optionBashFrameworkConfig}" ||
      Log::fatal "Command ${SCRIPT_NAME} - error while loading specific .framework-config file: ${optionBashFrameworkConfig}"
  else
    # shellcheck disable=SC2034
    BASH_FRAMEWORK_CONFIG_FILE=""
    # shellcheck source=/.framework-config
    Framework::loadConfig BASH_FRAMEWORK_CONFIG_FILE "${FRAMEWORK_ROOT_DIR}" ||
      Log::fatal "Command ${SCRIPT_NAME} - error while loading .framework-config file"
  fi

  if [[ "${optionConfig}" = "1" ]]; then
    displayConfig
  fi
}
