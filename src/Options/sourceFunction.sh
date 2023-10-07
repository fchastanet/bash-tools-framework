#!/usr/bin/env bash

# @description source the option file deduced by option function name
# @arg $1 functionName:String
# @env TMPDIR String the temp directory where the src file can be found
# @internal
Options::sourceFunction() {
  local functionName="$1"
  local tmpFile
  tmpFile="${TMPDIR}/src/$(sed -E -e 's#::#/#' <<<"${functionName}").sh"
  # shellcheck source=src/Options/testsData/generateOption.caseBoolean1.sh
  source "${tmpFile}"
}
