%
declare MIN_SHELLCHECK_VERSION="0.9.0"
declare versionNumber="1.0"
declare commandFunctionName="shellcheckLintCommand"
declare help="Lint bash files using shellcheck."
# shellcheck disable=SC2016
declare longDescription='''
shellcheck wrapper that will
- install new shellcheck version(${MIN_SHELLCHECK_VERSION}) automatically
- by default, lint all git files of this project which are beginning with a bash shebang
  except if the option --staged is passed

${__HELP_TITLE}Special configuration .shellcheckrc:${__HELP_NORMAL}
use the following line in your .shellcheckrc file to exclude
some files from being checked (use grep -E syntax)
exclude=^bin/bash-tpl$

${__HELP_TITLE_COLOR}SHELLCHECK HELP${__RESET_COLOR}

@@@SHELLCHECK_HELP@@@
'''
declare optionFormatAuthorizedValues="checkstyle|diff|gcc|json|json1|quiet|tty"
declare optionFormatDefault="tty"
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"

%
# shellcheck source=/dev/null
source <(
  Options::generateOption \
    --variable-type String \
    --help "define output format of this command(available: ${optionFormatAuthorizedValues}) (default: ${optionFormatDefault:-plain})" \
    --alt "--format" \
    --alt "-f" \
    --authorized-values "${optionFormatAuthorizedValues}" \
    --variable-name "optionFormat" \
    --function-name optionFormatFunction

  Options::generateOption \
    --help "lint only staged git files(files added to file list to be committed) and which are beginning with a bash shebang." \
    --alt "--staged" \
    --variable-name "optionStaged" \
    --function-name optionStagedFunction

  Options::generateOption \
    --help "uses parallelization(using xargs command) only if tty format" \
    --alt "--xargs" \
    --variable-name "optionXargs" \
    --function-name optionXargsFunction

  argShellcheckFilesCallback() { :; }
  Options::generateArg \
    --variable-name "argShellcheckFiles" \
    --min 0 \
    --max -1 \
    --name "shellcheckFiles" \
    --callback argShellcheckFilesCallback \
    --help "files to validate with shellcheck (if not provided, all files from git repository which are beginning with a bash shebang, unless --staged option is provided)" \
    --function-name argShellcheckFilesFunction
)
options+=(
  --callback shellcheckLintParseCallback
  --unknown-option-callback unknownOption
  optionFormatFunction
  optionStagedFunction
  optionXargsFunction
  argShellcheckFilesFunction
)
Options::generateCommand "${options[@]}"
%

declare copyrightBeginYear="2022"
declare optionFormat="<% ${optionFormatDefault} %>"
declare -a shellcheckArgs=()
declare -a shellcheckFiles=()

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
    Log::displayWarning "${SCRIPT_NAME} - --staged option ignored as files as been provided"
    optionStaged="0"
  fi
  if [[ "${optionFormat}" != "tty" && "${optionXargs}" = "1" ]]; then
    Log::displayWarning "--xargs option ignored as only supported with tty format"
    optionXargs="0"
  fi
  shellcheckArgs=(-f "${optionFormat}")
}

optionHelpCallback() {
  local shellcheckHelpFile
  shellcheckHelpFile="$(Framework::createTempFile "shellcheckHelp")"
  "${FRAMEWORK_VENDOR_BIN_DIR}/shellcheck" --help >"${shellcheckHelpFile}"

  <% ${commandFunctionName} %> help |
    sed -E \
      -e "/@@@SHELLCHECK_HELP@@@/r ${shellcheckHelpFile}" \
      -e "/@@@SHELLCHECK_HELP@@@/d"
  exit 0
}

optionVersionCallback() {
  echo -e "${__HELP_TITLE_COLOR}${SCRIPT_NAME} version: ${__RESET_COLOR} <% ${versionNumber} %>"
  echo -e -n "${__HELP_TITLE_COLOR}shellcheck Version: ${__RESET_COLOR}"
  "${FRAMEWORK_VENDOR_BIN_DIR}/shellcheck" --version
  exit 0
}
