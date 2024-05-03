%
declare versionNumber="1.0"
declare commandFunctionName="installRequirementsCommand"
declare help="installs requirements"
# shellcheck disable=SC2016
declare longDescription='''
${__HELP_TITLE}INSTALLS REQUIREMENTS:${__HELP_NORMAL}
- bats
'''
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"

%
Options::generateCommand "${options[@]}"
%

<% ${commandFunctionName} %> parse "${BASH_FRAMEWORK_ARGV[@]}"
