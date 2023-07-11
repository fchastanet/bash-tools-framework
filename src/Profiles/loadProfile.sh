#!/usr/bin/env bash

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
    Log::fatal "profile profile.${profile}.sh not found in '${profileDir}'"
  fi

  # shellcheck source=src/Profiles/testsData/profile.test1.sh
  source "${profileDir}/profile.${profile}.sh"

  if [[ ! -v CONFIG_LIST ]]; then
    Log::fatal "Profile ${profileDir}/profile.${profile}.sh missing variable CONFIG_LIST"
  fi
  if [[ ${#CONFIG_LIST[@]} -eq 0 ]]; then
    Log::fatal "Profile ${profileDir}/profile.${profile}.sh variable CONFIG_LIST cannot be empty"
  fi

  # remove duplicates from profile preserving order
  mapfile -t CONFIG_LIST < <(
    IFS=$'\n' printf '%s\n' "${CONFIG_LIST[@]}" | awk '!x[$0]++'
  )
  printf '%s\n' "${CONFIG_LIST[@]}"
}
