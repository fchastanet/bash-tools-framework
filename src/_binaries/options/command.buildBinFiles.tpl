%
declare versionNumber="1.1"
declare commandFunctionName="buildBinFilesCommand"
declare help="build files using compile
and check if bin file has been updated, if yes return exit code > 0

INTERNAL TOOL"
declare -a optionSrcDirsDefault=("src/_binaries")
%
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.base.tpl)"
.INCLUDE "$(dynamicTemplateDir _binaries/options/options.ci.tpl)"
%
# shellcheck source=/dev/null
source <(
Options::generateGroup \
    --title "BUILD OPTIONS:" \
    --function-name zzzGroupBuildOptionsFunction

Options::generateOption \
    --variable-type StringArray \
    --group zzzGroupBuildOptionsFunction \
    --help "list of directories from which files to build will be searched (default: ${optionSrcDirsDefault[*]})" \
    --callback validateSrcDirs \
    --alt "--src-dir" \
    --alt "-s" \
    --variable-name "optionSrcDirs" \
    --function-name optionSrcDirsFunction

Options::generateOption \
  --help "Do not exit with error for missing files. Useful when committing because some files were not existing before" \
  --group zzzGroupBuildOptionsFunction \
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
  --callback buildBinFilesCallback
  --unknown-option-callback unknownOption
  buildBinFilesArgsFunction
  optionIgnoreMissingFunction
  optionSrcDirsFunction
)
Options::generateCommand "${options[@]}"
%
# shellcheck disable=SC2317 # if function is overridden
unknownOption() {
  buildBinFilesArgs+=("$1")
}

# shellcheck disable=SC2317 # if function is overridden
buildBinFilesCallback() {
  if ((${#optionSrcDirs[@]} == 0)); then
    if [[ -n "${BINARIES_DIR:-}" ]]; then
      optionSrcDirs=("${BINARIES_DIR[@]}")
    else
      optionSrcDirs=(<% "${optionSrcDirsDefault[@]}" %>)
    fi
  fi
}

validateSrcDirs() {
  local dir
  local -i failures=0
  for dir in "${optionSrcDirs[@]}"; do
    Assert::dirExists "${dir}" || ((++failures))
  done
  return "${failures}"
}

declare copyrightBeginYear="2023"
