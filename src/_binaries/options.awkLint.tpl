%
declare versionNumber="1.0"
declare help="lint awk files

Lint all files with .awk extension in current git folder.
Result in checkstyle format."
%

.INCLUDE "$(dynamicTemplateDir _binaries/options.base.tpl)"

%
options+=(--help "${help}")

declare command
command="$(Options::generateCommand "${options[@]}")"
Options::sourceFunction "${command}"
%

helpCallback() {
  <% ${command} %> help
  exit 0
}

<% ${command} %> parse "${BASH_FRAMEWORK_ARGV[@]}"
