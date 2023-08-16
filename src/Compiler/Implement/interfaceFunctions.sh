#!/usr/bin/env bash

# @description try to find interface function in srcDirs
# and call it to output the interface's functions
# @arg $1 interfaceFunction:String the interface function to call
# @exitcode 1 on invalid function name
# @exitcode 2 on function not found
# @exitcode 3 on error during call to interface
# @exitcode 4 on invalid interface (no output or invalid list)
# @exitcode 5 on invalid interface (list of invalid function names)
# @stdout the interface's functions
# @stderr diagnostics information is displayed
# @see Compiler::Implement::interface
# @see Compiler::Implement::filter
# @see Compiler::Implement::parse
Compiler::Implement::interfaceFunctions() {
  local interfaceFunction="$1"

  if ! Assert::bashFrameworkFunction "${interfaceFunction}"; then
    Log::displayError "Interface '${interfaceFunction}' is not a valid bash framework function name"
    return 1
  fi

  # check if function exists
  local -a srcDirs
  readarray -t srcDirs < <(Compiler::Embed::getSrcDirsFromOptions "${_EMBED_COMPILE_ARGUMENTS[@]}")
  local interfaceFile
  interfaceFile="$(Compiler::findFunctionInSrcDirs "${interfaceFunction}" "${srcDirs[@]}")" || {
    Log::displayError "Interface '${interfaceFunction}' cannot be found in any src dirs: ${srcDirs[*]}"
    return 2
  }

  # call the function and check it is a list of strings that can be valid function names
  (
    # shellcheck source=/dev/null
    source "${interfaceFile}"
    local list
    list="$("${interfaceFunction}")" || {
      Log::displayError "Calling interface '${interfaceFunction}' has generated an error"
      return 3
    }
    if [[ -z "${list}" ]]; then
      Log::displayError "Calling interface '${interfaceFunction}' resulted to an empty functions list"
      return 4
    fi
    local functions
    readarray -t functions <<<"${list}" || {
      Log::displayError "Calling interface '${interfaceFunction}' resulted in invalid functions list"
      return 4
    }
    local functionItem
    for functionItem in "${functions[@]}"; do
      Assert::posixFunctionName "${functionItem}" || {
        Log::displayError "the function '${functionItem}' of interface '${interfaceFunction}' has an invalid posix name"
        return 5
      }
      echo "${functionItem}"
    done
  )
}
