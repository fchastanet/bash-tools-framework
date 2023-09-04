%
declare generateSkipDockerBuildOption=1
declare versionNumber="1.0"
declare commandFunctionName="docCommand"
declare help="Generate markdown documentation."
declare longDescription="""
INTERNAL TOOL
"""
%
.INCLUDE "$(dynamicTemplateDir _binaries/options.base.tpl)"
%
Options::generateCommand "${options[@]}"
%
