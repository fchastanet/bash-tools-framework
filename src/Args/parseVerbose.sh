#!/usr/bin/env bash

# @description change display level to verboseDisplayLevel argument if --verbose|-v option is parsed in arguments
# @arg $1 verboseDisplayLevel:String the level of verbosity to set
# @arg $@ args:String[] list of options
# @option -v short verbose option
# @option --verbose long verbose option
# @set ARGS_VERBOSE 1 if --verbose|-v option is parsed in arguments
# @set BASH_FRAMEWORK_DISPLAY_LEVEL to verboseDisplayLevel if --verbose|-v option is parsed in arguments
# @exitcode 1 if --verbose|-v option is not present in args list
Args::parseVerbose() {
  local verboseDisplayLevel="$1"
  declare -gx ARGS_VERBOSE=0
  shift || true
  local status=1
  while true; do
    if [[ "$1" = "--verbose" || "$1" = "-v" ]]; then
      status=0
      ARGS_VERBOSE=1
      break
    fi
    shift || break
  done
  if [[ "${status}" = "0" ]]; then
    export BASH_FRAMEWORK_DISPLAY_LEVEL=${verboseDisplayLevel}
  fi
  return "${status}"
}
