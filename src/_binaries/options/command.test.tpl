%
declare versionNumber="1.0"
declare commandFunctionName="testCommand"
declare help="Launch bats inside docker container"
# shellcheck disable=SC2016
declare longDescription='''
Launch bats inside docker container

${__HELP_TITLE}Examples:${__HELP_NORMAL}
to force image rebuilding
    DOCKER_BUILD_OPTIONS=--no-cache ./bin/test

rebuild alpine image
    DOCKER_BUILD_OPTIONS=--no-cache VENDOR=alpine BASH_IMAGE=bash:5.1 BASH_TAR_VERSION=5.1 ./bin/test

${__HELP_TITLE}In order to debug inside container:${__HELP_NORMAL}
    docker build -t bash-tools-ubuntu:5.1 -f .docker/Dockerfile.ubuntu
    docker run --rm -it -v \"\$(pwd):/bash\"  --user \"\$(id -u):\$(id -g)\"  bash-tools-ubuntu-5.1-user bash
    docker run --rm -it -v \"\$(pwd):/bash\"  --user \"\$(id -u):\$(id -g)\"  bash-tools-alpine-5.1-user bash

${__HELP_TITLE}Bats help:${__HELP_NORMAL}
@@@BATS_HELP@@@
'''
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.bashFrameworkDockerImage.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.ci.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.skipDockerBuild.tpl)"

%
# shellcheck source=/dev/null
source <(
  Options::generateArg \
    --variable-name "argBats" \
    --min 0 \
    --max -1 \
    --name "batsArgs" \
    --help "options passed to bats command" \
    --function-name argBatsFunction
)
options+=(
  --callback testParseCallback
  --every-option-callback everyOptOrArgCallback
  --every-argument-callback everyOptOrArgCallback
  argBatsFunction
)
Options::generateCommand "${options[@]}"
%

declare -a batsArgs=()
everyOptOrArgCallback() {
  if [[ -z "$1" || "$1" = "argBats" ]]; then
    batsArgs+=("$2")
    return 1
  fi
}

testParseCallback() {
  if ((${#batsArgs} == 0)); then
    batsArgs=(-r src)
  fi
}

optionHelpCallback() {
  local batsHelpFile
  batsHelpFile="$(Framework::createTempFile "batsHelp")"
  "${FRAMEWORK_VENDOR_DIR}/bats/bin/bats" --help >"${batsHelpFile}"

  <% ${commandFunctionName} %> help |
    sed -E \
      -e "/@@@BATS_HELP@@@/r ${batsHelpFile}" \
      -e "/@@@BATS_HELP@@@/d"
  exit 0
}


optionVersionCallback() {
  local batsVersion
  echo -e "${__HELP_TITLE_COLOR}${SCRIPT_NAME} version: ${__RESET_COLOR} <% ${versionNumber} %>"
  batsVersion="$("${FRAMEWORK_VENDOR_DIR}/bats/bin/bats" --version)"
  echo -e "${__HELP_TITLE_COLOR}bats version: ${__RESET_COLOR} ${batsVersion}"
  exit 0
}

getBatsLevel() {
  local levelName="$1"
  case "${levelName^^}" in
    TRACE) echo "--trace" ;;
    DEBUG) echo "--verbose-run" ;;
    *)
      # ignore
      return 1
  esac
}

updateArgListLogLevelCallback() {
  local level="$2"
  batsLevel="$(getBatsLevel "${level}")" || return 0
  batsArgs+=("${batsLevel}")
}

updateArgListDisplayLevelCallback() {
  local level="$2"
  if [[ "${IN_BASH_DOCKER:-}" = "You're in docker" ]]; then
    batsLevel="$(getBatsLevel "${level}")" || return 0
    batsArgs+=("${batsLevel}")
  else
    batsArgs+=("$1" "${level}")
  fi
}

updateArgListDebugVerboseCallback() {
  if [[ "${IN_BASH_DOCKER:-}" = "You're in docker" ]]; then
    batsArgs+=("--verbose-run")
  else
    batsArgs+=("-vv")
  fi
}
updateArgListTraceVerboseCallback() {
  if [[ "${IN_BASH_DOCKER:-}" = "You're in docker" ]]; then
    batsArgs+=("--trace")
  else
    batsArgs+=("-vvv")
  fi
}

addOptionsSpecificToRunBuildContainer() {
  if [[ "${IN_BASH_DOCKER:-}" != "You're in docker" ]]; then
    batsArgs+=("${@}")
  fi
}
updateOptionBashVersionCallback() {
  addOptionsSpecificToRunBuildContainer "$@"
}

updateOptionVendorCallback() {
  addOptionsSpecificToRunBuildContainer "$@"
}

updateOptionBashBaseImageCallback() {
  addOptionsSpecificToRunBuildContainer "$@"
}

updateOptionBranchNameCallback() {
  addOptionsSpecificToRunBuildContainer "$@"
}

updateOptionContinuousIntegrationMode() {
  addOptionsSpecificToRunBuildContainer "$@"
}

updateOptionSkipDockerBuildCallback() {
  addOptionsSpecificToRunBuildContainer "$@"
}
