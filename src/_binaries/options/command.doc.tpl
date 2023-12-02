%
declare generateSkipDockerBuildOption=1
declare versionNumber="1.0"
declare commandFunctionName="docCommand"
declare help="Generate markdown documentation."
declare longDescription="""
INTERNAL TOOL
"""
%
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.bashFrameworkDockerImage.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.ci.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.skipDockerBuild.tpl)"
%
Options::generateCommand "${options[@]}"
%
declare copyrightBeginYear="2022"

readonly defaultVendor="ubuntu"
readonly defaultBashVersion="5.1"
readonly defaultBashBaseImage="ubuntu:20.04"

declare -a RUN_CONTAINER_ARGV_FILTERED=()
updateOptionSkipDockerBuildCallback() {
  if [[ "${IN_BASH_DOCKER:-}" != "You're in docker" ]]; then
    BASH_FRAMEWORK_ARGV_FILTERED+=("$1")
    RUN_CONTAINER_ARGV_FILTERED+=("$1")
  fi
}
# shellcheck disable=SC2317 # if function is overridden
updateArgListInfoVerboseCallback() {
  RUN_CONTAINER_ARGV_FILTERED+=(--verbose)
  BASH_FRAMEWORK_ARGV_FILTERED+=(--verbose)
}
# shellcheck disable=SC2317 # if function is overridden
updateArgListDebugVerboseCallback() {
  RUN_CONTAINER_ARGV_FILTERED+=(-vv)
  BASH_FRAMEWORK_ARGV_FILTERED+=(-vv)
}
# shellcheck disable=SC2317 # if function is overridden
updateArgListTraceVerboseCallback() {
  RUN_CONTAINER_ARGV_FILTERED+=(-vvv)
  BASH_FRAMEWORK_ARGV_FILTERED+=(-vvv)
}
