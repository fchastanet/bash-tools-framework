#!/usr/bin/env bash

# @description parse IMPLEMENT directive
# @example
#   # IMPLEMENT namespace::functions
# @arg $1 str:String the directive to parse
# @arg $2 ref_interface:&String (passed by reference) the interface that needs to be implemented
# @exitcode 1 on invalid function name
# @exitcode 2 on function not found
# @exitcode 3 on error during call to interface
# @exitcode 4 on invalid interface (no output or invalid list)
# @exitcode 5 on invalid interface (list of invalid function names)
Compiler::Implement::parse() {
  local str="$1"
  local -n ref_interface=$2

  if [[ "${str}" =~ ^#\ IMPLEMENT\ (.+)$ ]]; then
    # shellcheck disable=SC2034
    ref_interface="$(echo "${BASH_REMATCH[1]}" | Filters::removeExternalQuotes)"

    Compiler::Implement::assertInterface "${ref_interface}" || return $?
  fi
}
