#!/usr/bin/env bash

# @description parse all the IMPLEMENT directives of given file
# and outputs the complete deduplicated list of interfaces
# @arg $1 scriptFile:String the file to parse
# @exitcode 1 if one of the IMPLEMENT directive failed to be parsed
# @exitcode 2 if an error occurred during grep
# @stderr diagnostics information is displayed
# @stdout the complete deduplicated list of interfaces
Compiler::Implement::interfaces() {
  local scriptFile="$1"
  local implementDirective
  local interface

  (
    Compiler::Implement::filter "${scriptFile}" | while IFS='' read -r implementDirective; do
      Compiler::Implement::parse "${implementDirective}" interface || {
        # already logged
        return 1
      }
      echo "${interface}"
    done
  ) | uniq
}
