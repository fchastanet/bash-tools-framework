#!/usr/bin/env bash

# @description ensure env files are loaded
# @noargs
# @exitcode 1 if getOrderedConfFiles fails
# @exitcode 2 if one of env files fails to load
# @stderr diagnostics information is displayed
Env::requireLoad() {
  local configFilesStr
  configFilesStr="$(Env::getOrderedConfFiles)" || return 1

  local -a configFiles
  readarray -t configFiles <<<"${configFilesStr}"

  # if empty string, there will be one element
  if ((${#configFiles[@]} == 0)) || [[ -z "${configFilesStr}" ]]; then
    # should not happen, as there is always default file
    Log::displaySkipped "no env file to load"
    return 0
  fi

  Env::mergeConfFiles "${configFiles[@]}" || {
    Log::displayError "while loading config files: ${configFiles[*]}"
    return 2
  }
}
