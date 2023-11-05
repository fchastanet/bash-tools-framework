%
declare MIN_HADOLINT_VERSION="2.12.0"
declare versionNumber="1.0"
declare commandFunctionName="dockerLintCommand"
declare help="Lint docker files of the given directory using hadolint."
# shellcheck disable=SC2016
declare longDescription='''
- installs new hadolint version(>${MIN_HADOLINT_VERSION}) automatically
- lint this project files using default files filter

${__HELP_TITLE_COLOR}HADOLINT HELP${__RESET_COLOR}

@@@HADOLINT_HELP@@@
'''
%

declare MIN_HADOLINT_VERSION="<% ${MIN_HADOLINT_VERSION} %>"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"


optionHelpCallback() {
  local hadolintHelpFile
  hadolintHelpFile="$(Framework::createTempFile "hadolintHelp")"
  "${FRAMEWORK_VENDOR_BIN_DIR}/hadolint" --help >"${hadolintHelpFile}"

  <% ${commandFunctionName} %> help |
    sed -E \
      -e "/@@@HADOLINT_HELP@@@/r ${hadolintHelpFile}" \
      -e "/@@@HADOLINT_HELP@@@/d"
  exit 0
}

optionVersionCallback() {
  echo -e "${__HELP_TITLE_COLOR}${SCRIPT_NAME} version: ${__RESET_COLOR} <% ${versionNumber} %>"
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

%
options+=(
  --unknown-option-callback unknownOption
  --unknown-argument-callback unknownArg
)
Options::generateCommand "${options[@]}"
%
declare copyrightBeginYear="2022"
