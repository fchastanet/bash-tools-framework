%
declare versionNumber="1.0"
declare commandFunctionName="buildBinFilesCommand"
declare help="build files using compile
and check if bin file has been updated, if yes return exit code > 0

INTERNAL TOOL"

%
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.ci.tpl)"
%
# shellcheck source=/dev/null
source <(
Options::generateOption \
  --help "Do not exit with error for missing files. Useful when committing because some files were not existing before" \
  --alt "--ignore-missing" \
  --variable-name "optionIgnoreMissing" \
  --function-name optionIgnoreMissingFunction

Options::generateArg \
  --variable-name "buildBinFilesArgs" \
  --min 0 \
  --max -1 \
  --name "arg" \
  --help "command arguments including command name" \
  --function-name buildBinFilesArgsFunction
)

options+=(
  --unknown-option-callback unknownOption
  buildBinFilesArgsFunction
  optionIgnoreMissingFunction
)
Options::generateCommand "${options[@]}"
%
# shellcheck disable=SC2317 # if function is overridden
unknownOption() {
  buildBinFilesArgs+=("$1")
}
declare copyrightBeginYear="2023"
