%
declare versionNumber="1.0"
declare commandFunctionName="awkLintCommand"
declare help="lint awk files

Lint all files with .awk extension in current git folder.
Result in checkstyle format."
%

.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"

%
Options::generateCommand "${options[@]}"
%
declare copyrightBeginYear="2022"
