#!/usr/bin/env bash

# @description load profile file based on profileDir and profile argument
# The profile file is ${profileDir}/profile.${profile}.sh
# This file should define the variable CONFIG_LIST with array type
# @warning warning
# @arg $1 arg1Name:arg1Type
# @arg $@ args:String[]
# @set envVar type description
# @env envVar type description
# @exitcode 1 if one of the 2 arguments is not provided
# @exitcode 2 if profile not found at location ${profileDir}/profile.${profile}.sh
# @exitcode 3 if profile found but CONFIG_LIST variable unset
# @exitcode 4 if profile found but CONFIG_LIST variable empty
# @exitcode 5 if error occurs during profile loading
# @stdout list of unique config items provided by profile's CONFIG_LIST array
# @stderr diagnostics information is displayed
# @see Profiles::allDepsRecursive in order to load all the dependencies recursively based on this list
Profiles::loadProfile() {
  local profileDir="$1"
  local profile="$2"
  local -a CONFIG_LIST=()

  if [[ -z "${profile}" || -z "${profileDir}" ]]; then
    Log::displayError "This method needs exactly 2 parameters"
    return 1
  fi

  # load the profile
  Log::displayInfo "Loading profile '${profileDir}/profile.${profile}.sh'"
  if [[ ! -f "${profileDir}/profile.${profile}.sh" ]]; then
    Log::displayError "profile profile.${profile}.sh not found in '${profileDir}'"
    return 2
  fi

  # shellcheck source=src/Profiles/testsData/profile.test1.sh
  source "${profileDir}/profile.${profile}.sh" || return 5

  if [[ ! -v CONFIG_LIST ]]; then
    Log::displayError "Profile ${profileDir}/profile.${profile}.sh missing variable CONFIG_LIST"
    return 3
  fi
  if [[ ${#CONFIG_LIST[@]} -eq 0 ]]; then
    Log::displayError "Profile ${profileDir}/profile.${profile}.sh variable CONFIG_LIST cannot be empty"
    return 4
  fi

  # remove duplicates from profile preserving order
  mapfile -t CONFIG_LIST < <(
    IFS=$'\n' printf '%s\n' "${CONFIG_LIST[@]}" | awk '!x[$0]++'
  )
  printf '%s\n' "${CONFIG_LIST[@]}"
}
