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
