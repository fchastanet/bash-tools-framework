#!/usr/bin/env bash

Profiles::loadProfile() {
  local profileDir="$1"
  shift 2 || true
  local profile="$1"

  local -a CONFIG_LIST=()

  # load the profile
  if [[ -z "${profile}" ]]; then
    shift
    CONFIG_LIST=("$@")
  else
    Log::displayInfo "Loading profile '${profileDir}/profile.${profile}.sh'"
    if [[ ! -f "${profileDir}/profile.${profile}.sh" ]]; then
      Log::fatal "profile profile.${profile}.sh not found in '${profileDir}'"
    fi
    # shellcheck source=/src/Profiles/testsData/profile.test1.sh
    source "${profileDir}/profile.${profile}.sh"
  fi
  if [[ ! -v CONFIG_LIST ]]; then
    Log::fatal "Profile ${profileDir}/profile.${profile}.sh missing variable CONFIG_LIST"
  fi
  if [[ ${#CONFIG_LIST[@]} -eq 0 ]]; then
    Log::fatal "Profile ${profileDir}/profile.${profile}.sh variable CONFIG_LIST cannot be empty"
  fi

  # remove duplicates from profile preserving order
  mapfile -t CONFIG_LIST < <(
    IFS=$'\n'
    echo "${CONFIG_LIST[*]}" | awk '!x[$0]++'
  )
  echo "${CONFIG_LIST[@]}"

}
