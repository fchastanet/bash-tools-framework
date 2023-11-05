%
declare generateSkipDockerBuildOption=1
declare versionNumber="1.0"
declare commandFunctionName="runBuildContainerCommand"
declare help="run the container eventually building the docker image before."
# shellcheck disable=SC2016
declare longDescription='''
run the container specified by args provided.
Command to run is passed via the rest of arguments.
TTY allocation is detected automatically.

additional env variables can be passed to docker build:
  - ${__HELP_OPTION_COLOR}SKIP_USER${__HELP_NORMAL} (default: 0)
  - ${__HELP_OPTION_COLOR}USER_ID${__HELP_NORMAL} (default: current user id provided by (id -u) command)
  - ${__HELP_OPTION_COLOR}GROUP_ID${__HELP_NORMAL} (default: current group id provided by (id -g) command)

additional docker run options can be passed
  via ${__HELP_OPTION_COLOR}DOCKER_RUN_OPTIONS${__HELP_NORMAL} env variable
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
    --variable-name "dockerRunCmd" \
    --min 0 \
    --max -1 \
    --name "arg" \
    --help "command arguments including command name" \
    --function-name dockerRunCmdFunction
)
options+=(
  --unknown-option-callback unknownOption
  dockerRunCmdFunction
)
Options::generateCommand "${options[@]}"
%
declare copyrightBeginYear="2022"

# shellcheck disable=SC2317 # if function is overridden
unknownOption() {
  dockerRunCmd+=("$1")
}
# shellcheck disable=SC2317 # if function is overridden
updateArgListInfoVerboseCallback() {
  RUN_CONTAINER_ARGV_FILTERED+=(--verbose)
}
# shellcheck disable=SC2317 # if function is overridden
updateArgListDebugVerboseCallback() {
  RUN_CONTAINER_ARGV_FILTERED+=(-vv)
}
# shellcheck disable=SC2317 # if function is overridden
updateArgListTraceVerboseCallback() {
  RUN_CONTAINER_ARGV_FILTERED+=(-vvv)
}
