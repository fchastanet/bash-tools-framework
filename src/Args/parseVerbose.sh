#!/usr/bin/env bash

# change display level to level argument
# if --verbose|-v option is parsed in arguments
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
