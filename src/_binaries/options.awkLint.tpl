%
declare versionNumber="1.0"
declare help="lint awk files

Lint all files with .awk extension in current git folder.
Result in checkstyle format."
%

.INCLUDE "$(dynamicTemplateDir _binaries/options.base.tpl)"

helpCallback() {
  awkLintCommand help
  exit 0
}

%
options+=(
  --help "${help}"
  --command-name awkLint
  --function-name awkLintCommand
)

Options::generateCommand "${options[@]}"
%
