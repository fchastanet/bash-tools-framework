#!/usr/bin/env bash

# @description source option file deduced by option function name
# @arg $1 functionName:String
Options::sourceFunction() {
  local functionName="$1"
  local tmpFile
  tmpFile="${TMPDIR}/src/$(sed -E -e 's#::#/#' <<<"${functionName}").sh"
  # shellcheck source=src/Options/testsData/generateOption.caseBoolean1.sh
  source "${tmpFile}"
}
