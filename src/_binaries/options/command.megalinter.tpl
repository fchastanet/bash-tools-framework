%
declare defaultMegalinterConfigFile=".mega-linter.yml"
declare defaultMegalinterImage=oxsecurity/megalinter-terraform:v7.4.0
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
declare optionMegalinterImage="${defaultMegalinterImage}"
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
    --help "Specify docker megalinter image name to use" \
    --alt "--image" \
    --variable-name "optionMegalinterImage" \
    --default-value "${defaultMegalinterImage}" \
    --function-name optionMegalinterImageFunction

  Options::generateOption \
    --variable-type "String" \
    --help "Specify megalinter config filename to use" \
    --alt "--config-file" \
    --default-value "${defaultMegalinterConfigFile}" \
    --variable-name "optionMegalinterConfigFile" \
    --function-name optionMegalinterConfigFileFunction

  Options::generateOption \
    --help "Check if new version of megalinter is available (compared to ${defaultMegalinterImage}) and exit 1 if yes and display new version number." \
    --alt "--check-megalinter-version" \
    --variable-name "optionCheckMegalinterVersion" \
    --function-name optionCheckMegalinterVersionFunction
)

options+=(
  --unknown-argument-callback unknownArg
  --callback commandCallback
  optionFixFunction
  optionFilesOnlyFunction
  optionIncrementalFunction
  optionMegalinterImageFunction
  optionCheckMegalinterVersionFunction
  optionMegalinterConfigFileFunction
)
Options::generateCommand "${options[@]}"
%
declare copyrightBeginYear="2022"
declare optionMegalinterConfigFile="<% ${defaultMegalinterConfigFile} %>"
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

checkMegalinterVersionAndExit() {
  local newVersion
  Github::getLatestRelease "oxsecurity/megalinter" newVersion
  local currentVersion
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
  esac
  exit 0
}

commandCallback() {
  if [[ "${optionCheckMegalinterVersion}" = "1" ]]; then
    checkMegalinterVersionAndExit
  fi
  if [[ "${optionIncremental}" = "1"  ]] && ((${#megalinterArgs[@]}>0)); then
    Log::fatal "you cannot provide a list of files and the --incremental option"
  fi
  if (( ${#megalinterArgs[@]} > 0 )); then
    megalinterOptions+=(
      -e MEGALINTER_FILES_TO_LINT="$(Array::join "," "${megalinterArgs[@]}")"
    )
  fi
}

optionFixCallback() {
  megalinterOptions+=(-e APPLY_FIXES=all)
}

optionVersionCallback() {
  echo -e "${__HELP_TITLE_COLOR}${SCRIPT_NAME} version:${__RESET_COLOR} <% ${versionNumber} %>"
  echo -e "${__HELP_TITLE_COLOR}megalinter image Version:${__RESET_COLOR} <% ${optionMegalinterImage} %>"
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
