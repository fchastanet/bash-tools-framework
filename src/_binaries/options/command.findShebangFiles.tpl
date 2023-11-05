%
declare versionNumber="1.0"
declare commandFunctionName="findShebangFiles"
declare help="find all shebang files of this repository"
# shellcheck disable=SC2016
declare longDescription='''
display list of all files having a bash shebang in the current repository

you can apply a command to all these files by providing arguments

${__HELP_TITLE}Example:${__HELP_NORMAL}
add execution bit to all files with a bash shebang
${SCRIPT_NAME} chmod +x
'''
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"

%
options+=(
  --unknown-option-callback unknownOptionArgFunction
  --unknown-argument-callback unknownOptionArgFunction
)
Options::generateCommand "${options[@]}"
%
declare copyrightBeginYear="2023"
