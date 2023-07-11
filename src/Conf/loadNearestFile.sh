#!/usr/bin/env bash

# Load the nearest config file
# eg: Conf::loadNearestFile ".framework-config" "srcDir1" "srcDir2"
# will search first .framework-config file in "srcDir1"
# then if not found will go in up directories until /
# then will search in "srcDir2"
# then if not found will go in up directories until /
# source the file if found
# @param {String} $1 config file name to search
# @param {String} $2 passed by reference, will return the loaded config file name
# @param {String} $@ source directories in which the config file will be searched
# @return 0 if file found, 1 if file not found
# @output the filepath loaded if any
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

  Log::displayWarning "Config file '${configFileName}' not found in any source directories provided"
  return 1
}
