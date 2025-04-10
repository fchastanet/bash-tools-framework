#!/usr/bin/env bash

# @description Load the nearest config file
# in next example will search first .framework-config file in "srcDir1"
# then if not found will go in up directories until /
# then will search in "srcDir2"
# then if not found will go in up directories until /
# source the file if found
# @example
#   Conf::loadNearestFile ".framework-config" "srcDir1" "srcDir2"
#
# @arg $1 configFileName:String config file name to search
# @arg $2 loadedFile:String (passed by reference) will return the loaded config file name
# @arg $@ srcDirs:String[] source directories in which the config file will be searched
# @exitcode 0 if file found
# @exitcode 1 if file not found
Conf::loadNearestFile() {
  local configFileName="$1"
  local -n loadedFile="$2"
  shift 2 || true
  local -a srcDirs=("$@")
  for srcDir in "${srcDirs[@]}"; do
    configFile="$(File::upFind "${srcDir}" "${configFileName}" || true)"
    if [[ -n "${configFile}" ]]; then
      # shellcheck source=/.framework-config
      source "${configFile}" || Log::fatal "error while loading config file '${configFile}'"
      Log::displayDebug "Config file ${configFile} is loaded"
      # shellcheck disable=SC2034
      loadedFile="${configFile}"
      return 0
    fi
  done

  Log::displayDebug "Config file '${configFileName}' not found in any source directories provided"
  return 1
}
