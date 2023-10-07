#!/usr/bin/env bash

rootDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)"
export FRAMEWORK_ROOT_DIR="${rootDir}"
export _COMPILE_ROOT_DIR="${rootDir}"
srcDir="$(cd "${rootDir}/src" && pwd -P)"

# shellcheck source=src/Options/__all.sh
source "${srcDir}/Options/__all.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

# @description source option file deduced by option function name
# @arg $1 functionName:String
sourceFunctionFile() {
  local functionName="$1"
  local tmpFile
  tmpFile="${TMPDIR}/src/$(sed -E -e 's#::#/#' <<<"${functionName}").sh"
  # shellcheck source=src/Options/testsData/generateOption.caseBoolean1.sh
  source "${tmpFile}"
}

set -o errexit
set -o pipefail
export TMPDIR="/tmp"

set -x
declare optionGroup
optionGroup="$(Options::generateGroup \
  --title "GLOBAL OPTIONS:" \
  --help "The Console component adds some predefined options to all commands:")"
sourceFunctionFile "${optionGroup}"

declare optionVerbose
optionVerbose="$(Options::generateOption --help "verbose mode" \
  --group "${optionGroup}" \
  --variable-name "verbose" \
  --alt "--verbose" --alt "-v")"
sourceFunctionFile "${optionVerbose}"

declare optionSrcDirs
optionSrcDirs="$(Options::generateOption --variable-type StringArray \
  --help "provide the directory where to find the functions source code." \
  --variable-name "srcDirs" --alt "--src-dirs" --alt "-s")"
sourceFunctionFile "${optionSrcDirs}"

declare optionQuiet
optionQuiet="$(Options::generateOption --help "quiet mode" \
  --group "${optionGroup}" \
  --variable-name "quiet" \
  --alt "--quiet" --alt "-q")"
sourceFunctionFile "${optionQuiet}"

declare srcFile
srcFile="$(Options::generateArg --variable-name "srcFile")" || return 1
sourceFunctionFile "${srcFile}"

declare destFiles
destFiles="$(Options::generateArg --variable-name "destFiles" --max 3)" || return 1
sourceFunctionFile "${destFiles}"

command=$(Options::generateCommand --help "super command" \
  "${optionVerbose}" \
  "${optionSrcDirs}" \
  "${optionQuiet}" \
  "${srcFile}" \
  "${destFiles}")
sourceFunctionFile "${command}"

set +x
"${command}" help
