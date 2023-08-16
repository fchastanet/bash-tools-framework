#!/usr/bin/env bash

# @description parse all the IMPLEMENT directives of given file
# and outputs the complete deduplicated list of interfaces's functions
# @arg $1 scriptFile:String the file to parse
# @exitcode 1 if one of the IMPLEMENT directive failed to be parsed
# @exitcode 2 if an error occurred during grep
# @stdout the complete deduplicated list of interfaces's functions
# @stderr diagnostics information is displayed
# @see Compiler::Implement::interfaces
# @see Compiler::Implement::interfaceFunctions
Compiler::Implement::mergeInterfacesFunctions() {
  local scriptFile="$1"
  local interface

  (
    Compiler::Implement::interfaces "${scriptFile}" | while IFS='' read -r interface; do
      Compiler::Implement::interfaceFunctions "${interface}" || {
        # already logged
        return 1
      }
    done
  ) | uniq
}
