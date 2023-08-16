#!/usr/bin/env bash

# @description ensure all functions passed in parameters are implemented
# as function in given file
# @arg $1 file:String file to filter
# @arg $2 originalFile:String the original file name (to use in logs)
# @arg $@ functions:String[] list of functions to match
# @exitcode 1 if file does not exist
# @exitcode 2 if a function is not found
Compiler::Implement::validateInterfaceFunctions() {
  local file="$1"
  shift || true
  local originalFile="$1"
  shift || true

  if [[ ! -f "${file}" ]]; then
    Log::displayError "missing file ${file}"
    return 1
  fi
  if (($# == 0)); then
    return 0
  fi
  for func in "$@"; do
    grep -q -E -e "^${func}\(\)[ \t]*\{$" "${file}" || {
      Log::displayError "function ${func} from interface is not implemented in ${originalFile}"
      return 2
    }
  done
}
