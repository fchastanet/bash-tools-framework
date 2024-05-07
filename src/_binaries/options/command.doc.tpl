%
declare generateSkipDockerBuildOption=1
declare versionNumber="1.1"
declare commandFunctionName="docCommand"
declare help="Generate markdown documentation."
declare longDescription="""
INTERNAL TOOL
"""
%
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.ci.tpl)"
%
Options::generateCommand "${options[@]}"
%
declare copyrightBeginYear="2022"
