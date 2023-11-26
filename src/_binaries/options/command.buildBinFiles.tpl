%
declare versionNumber="1.0"
declare commandFunctionName="buildBinFilesCommand"
declare help="build files using compile
and check if bin file has been updated, if yes return exit code > 0

INTERNAL TOOL"

%
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
%
# shellcheck source=/dev/null
source <(
Options::generateOption \
  --help "Do not exit with error for missing files. Useful when committing because some files were not existing before" \
  --alt "--ignore-missing" \
  --variable-name "optionIgnoreMissing" \
  --function-name optionIgnoreMissingFunction
)
options+=(
  optionIgnoreMissingFunction
)
Options::generateCommand "${options[@]}"
%
declare copyrightBeginYear="2023"
