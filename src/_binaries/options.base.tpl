%# Needed variables
%# - versionNumber
%# - commandFunctionName
%# - SCRIPT_NAME
%# - help
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
      --help "info level verbose mode (alias of --display-level INFO)" \
      --group groupGlobalOptionsFunction \
      --alt "--verbose" --alt "-v" \
      --callback optionInfoVerboseCallback \
      --variable-name "optionInfoVerbose" \
      --function-name optionInfoVerboseFunction

    Options::generateOption \
      --help "debug level verbose mode (alias of --display-level DEBUG)" \
      --group groupGlobalOptionsFunction \
      --alt "-vv" \
      --callback optionDebugVerboseCallback \
      --variable-name "optionDebugVerbose" \
      --function-name optionDebugVerboseFunction

    Options::generateOption \
      --help "trace level verbose mode (alias of --display-level TRACE)" \
      --group groupGlobalOptionsFunction \
      --alt "-vvv" \
      --callback optionTraceVerboseCallback \
      --variable-name "optionTraceVerbose" \
      --function-name optionTraceVerboseFunction

    Options::generateOption \
      --variable-type StringArray \
      --help "Load the specified env file" \
      --group groupGlobalOptionsFunction \
      --alt "--env-file" \
      --max -1 \
      --callback optionEnvFileCallback \
      --variable-name "optionEnvFiles" \
      --function-name optionEnvFilesFunction

    Options::generateOption \
      --variable-type String \
      --help "Set log level (one of OFF, ERROR, WARNING, INFO, DEBUG, TRACE value)" \
      --group groupGlobalOptionsFunction \
      --alt "--log-level" \
      --authorized-values "OFF|ERROR|WARNING|INFO|DEBUG|TRACE" \
      --callback "optionLogLevelCallback" \
      --variable-name "optionLogLevel" \
      --function-name optionLogLevelFunction

    Options::generateOption \
      --variable-type String \
      --help "Set log file" \
      --group groupGlobalOptionsFunction \
      --alt "--log-file" \
      --callback "optionLogFileCallback" \
      --variable-name "optionLogFile" \
      --function-name optionLogFileFunction

    Options::generateOption \
      --variable-type String \
      --help "set display level (one of OFF, ERROR, WARNING, INFO, DEBUG, TRACE value)" \
      --group groupGlobalOptionsFunction \
      --alt "--display-level" \
      --authorized-values "OFF|ERROR|WARNING|INFO|DEBUG|TRACE" \
      --callback optionDisplayLevelCallback \
      --variable-name "optionDisplayLevel" \
      --function-name optionDisplayLevelFunction

    Options::generateOption \
      --help "Produce monochrome output. alias of --theme noColor." \
      --group groupGlobalOptionsFunction \
      --alt "--no-color" \
      --callback optionNoColorCallback \
      --variable-name "optionNoColor" \
      --function-name optionNoColorFunction

    Options::generateOption \
      --variable-type String \
      --help "choose color theme (default or noColor)" \
      --group groupGlobalOptionsFunction \
      --alt "--theme" \
      --authorized-values "default|noColor" \
      --callback optionThemeCallback \
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
      --variable-name "optionQuiet" \
      --function-name optionQuietFunction

    if [[ "${generateFormatOption:-0}" = "1" ]]; then
      Options::generateOption \
        --variable-type String \
        --help "define output format of this command (default: plain)" \
        --alt "--format" \
        --authorized-values "plain|checkstyle" \
        --variable-name "optionFormat" \
        --function-name optionFormatFunction
    fi
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
  if [[ "${generateFormatOption:-0}" = "1" ]]; then
    options+=(optionFormatFunction)
  fi
%

# default option values
% if [[ "${generateFormatOption:-0}" = "1" ]]; then
  declare optionFormat="plain"
% fi

optionHelpCallback() {
  <% ${commandFunctionName} %> help
  exit 0
}

optionVersionCallback() {
  echo "${SCRIPT_NAME} version <% ${versionNumber} %>"
  exit 0
}

optionEnvFileCallback() {
  local envFile="$1"
  if [[ ! -f "${envFile}" || ! -r "${envFile}" ]]; then
    Log::displayError "Option --env-file - File '${envFile}' doesn't exist"
    exit 1
  fi
}

optionInfoVerboseCallback() {
  export BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='--verbose'
  export BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_INFO}
  export BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_INFO}
}

optionDebugVerboseCallback() {
  export BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='-vv'
  export BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_DEBUG}
  export BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_DEBUG}
}

optionTraceVerboseCallback() {
  export BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='-vvv'
  export BASH_FRAMEWORK_ARGS_VERBOSE=${__VERBOSE_LEVEL_TRACE}
  export BASH_FRAMEWORK_DISPLAY_LEVEL=${__LEVEL_DEBUG}
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
      Log::displayError "Invalid level ${level}"
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
      Log::displayError "Invalid level ${level}"
      return 1
  esac
}

optionDisplayLevelCallback() {
  local level="$1"
  local logLevel verboseLevel
  logLevel="$(getLevel "${level}")"
  verboseLevel="$(getVerboseLevel "${level}")"
  export BASH_FRAMEWORK_ARGS_VERBOSE=${verboseLevel}
  export BASH_FRAMEWORK_DISPLAY_LEVEL=${logLevel}
}

optionLogLevelCallback() {
  local level="$1"
  local logLevel verboseLevel
  logLevel="$(getLevel "${level}")"
  verboseLevel="$(getVerboseLevel "${level}")"
  export BASH_FRAMEWORK_ARGS_VERBOSE=${verboseLevel}
  export BASH_FRAMEWORK_LOG_LEVEL=${logLevel}
}

optionLogFileCallback() {
  local logFile="$1"
  export BASH_FRAMEWORK_LOG_FILE="${logFile}"
}

optionQuietCallback() {
  export BASH_FRAMEWORK_QUIET_MODE=1
}

optionNoColorCallback() {
  UI::theme "noColor"
}

optionThemeCallback() {
  UI::theme "$1"
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

commandOptionParseFinished() {
  if [[ -z "${BASH_FRAMEWORK_ENV_FILES[0]+1}" ]]; then
    BASH_FRAMEWORK_ENV_FILES=()
  fi
  BASH_FRAMEWORK_ENV_FILES+=("${optionEnvFiles[@]}")
  export BASH_FRAMEWORK_ENV_FILES
  Env::requireLoad
  Log::requireLoad
  if [[ "${optionConfig}" = "1" ]]; then
    displayConfig
  fi
}
