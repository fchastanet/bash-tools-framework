#!/usr/bin/env bash

# @description parse @require directive
# @example
#   # @require Namespace::requireSomething
# @arg $1 str:String the directive to parse
# @arg $2 ref_requireFunctionName:&String (passed by reference) the function name implementing the requirement
# @exitcode 1 on invalid function name
# @exitcode 2 on function name not using require format
# @exitcode 3 on function not found
Compiler::Require::parse() {
  local str="$1"
  local -n ref_requireFunctionName=$2

  if [[ "${str}" =~ ^#\ @require\ (.+)$ ]]; then
    # shellcheck disable=SC2034
    ref_requireFunctionName="$(echo "${BASH_REMATCH[1]}" | Filters::removeExternalQuotes)"

    Compiler::Require::assertRequire "${ref_requireFunctionName}" || return $?
  fi
}
