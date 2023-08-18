#!/usr/bin/env bash

# @description check if dependencies exist
# path is constructed with following rule
#   ${scriptsDir}/${dependency}${extension}
# @arg $1 scriptsDir:String
# @arg $2 extension:String
# @arg $@ args:String[] list of dependencies to check
# @exitcode 1 if one the script does not exist
# @stderr diagnostics information is displayed
Profiles::checkScriptsExistence() {
  local scriptsDir="$1"
  local extension="$2"
  shift 2 || true

  for i in "$@"; do
    if [[ ! -f "${scriptsDir}/${i}${extension}" ]]; then
      Log::fatal "script ${i} doesn't exist"
    fi
  done
}
