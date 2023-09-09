%
declare defaultMegalinterImage=oxsecurity/megalinter-terraform:v6.16.0
declare versionNumber="1.0"
declare commandFunctionName="megalinterCommand"
declare help="run megalinter over this repository."
# shellcheck disable=SC2016
declare longDescription="""
megalinter image ${defaultMegalinterImage} will be used.

<files> optionally you can provide a list of files to run megalinter on
  this mode is incompatible with --incremental option
"""
declare optionFormatAuthorizedValues="plain|json"
declare optionFormatDefault="plain"
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.format.tpl)"

%

# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --help "Apply linters fixes automatically." \
    --alt "--fix" \
    --callback optionFixCallback \
    --variable-name "optionFix" \
    --function-name optionFixFunction

  Options::generateOption \
    --help "Skip linters that run in project mode." \
    --alt "--filesOnly" \
    --callback filesOnlyCallback \
    --variable-name "optionFilesOnly" \
    --function-name optionFilesOnlyFunction

  Options::generateOption \
    --help "Run megalinter only on files that are git staged" \
    --alt "--incremental" \
    --alt "-i" \
    --variable-name "optionIncremental" \
    --function-name optionIncrementalFunction

  Options::generateOption \
    --variable-type "String" \
    --help "Specify docker megalinter image name to use (default: ${defaultMegalinterImage})" \
    --alt "--image" \
    --variable-name "optionMegalinterImage" \
    --function-name optionMegalinterImageFunction
)

options+=(
  --unknown-argument-callback unknownArg
  --callback commandCallback
  optionFixFunction
  optionFilesOnlyFunction
  optionIncrementalFunction
  optionMegalinterImageFunction
)
Options::generateCommand "${options[@]}"
%

declare optionMegalinterImage="<% ${defaultMegalinterImage} %>"
declare -a megalinterArgs=()
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

commandCallback() {
  if [[ "${optionIncremental}" = "1"  ]] && ((${#megalinterArgs[@]}>0)); then
    Log::fatal "you cannot provide a list of files and the --incremental option"
  fi
  megalinterOptions+=(
    -e MEGALINTER_FILES_TO_LINT="$(Array::join "," "${megalinterArgs[@]}")"
  )
}

optionFixCallback() {
  megalinterOptions+=(-e APPLY_FIXES=all)
}

optionVersionCallback() {
  echo -e "${__HELP_TITLE_COLOR}${SCRIPT_NAME} version: ${__RESET_COLOR} <% ${versionNumber} %>"
  echo -e "${__HELP_TITLE_COLOR}megalinter image Version: ${__RESET_COLOR} <% ${optionImageVersion} %>"
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
