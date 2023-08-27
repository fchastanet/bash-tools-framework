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

declare srcFile
srcFile="$(Options::generateArg --variable-name "srcFile")" || return 1
sourceFunctionFile "${srcFile}"

declare destFiles
destFiles="$(Options::generateArg --variable-name "destFiles" --max 3)" || return 1
sourceFunctionFile "${destFiles}"

Options::generateCommand --help "super command" \
  "${destFiles}" \
  "${srcFile}"
