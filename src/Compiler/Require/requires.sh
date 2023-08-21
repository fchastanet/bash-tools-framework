#!/usr/bin/env bash

# @description parse all the @require directives of given file
# and outputs the complete deduplicated list of requires
# @arg $1 scriptFile:String the file to parse
# @exitcode 1 if one of the @require directive failed to be parsed
# @exitcode 2 if an error occurred during grep
# @stderr diagnostics information is displayed
# @stdout the complete list of requires using scriptFile order
Compiler::Require::requires() {
  local scriptFile="$1"
  local requireDirective
  local requireFunction

  local filteredRequiresTmpFile
  filteredRequiresTmpFile="$(Framework::createTempFile "requires")"
  Compiler::Require::filter "${scriptFile}" |
    Filters::uniqUnsorted >"${filteredRequiresTmpFile}" || return 2

  (
    while IFS='' read -r requireDirective; do
      Compiler::Require::parse "${requireDirective}" requireFunction || {
        # already logged
        return 1
      }
      echo "${requireFunction}"
    done <"${filteredRequiresTmpFile}"
  )
}
