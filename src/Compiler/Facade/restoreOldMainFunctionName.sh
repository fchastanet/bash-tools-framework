#!/usr/bin/env bash

# @description if scriptFile already exists, retrieve previous main function name
# in order to avoid constructBinFile to fail at each commit
# @arg $1 targetBinFile:String the binary file being generated
# @stdin this command supports filter on stdin piped to grep or via file argument passed to grep
# @exitcode 2 if an error occurred during grep
Compiler::Facade::restoreOldMainFunctionName() {
  local targetBinFile=$1
  local mainFunctionName=""
  if [[ -f "${targetBinFile}" ]]; then
    mainFunctionName="$(
      grep -m 1 -o -E 'facade_main_[0-9a-f]{8}[0-9a-f]{4}4[0-9a-f]{3}[89ab][0-9a-f]{3}[0-9a-f]{12}' "${targetBinFile}"
    )" || true
  fi

  if [[ -n "${mainFunctionName}" ]]; then
    sed -E "s/facade_main_[0-9a-f]{8}[0-9a-f]{4}4[0-9a-f]{3}[89ab][0-9a-f]{3}[0-9a-f]{12}/${mainFunctionName}/g"
  else
    cat
  fi
}
