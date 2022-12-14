#!/usr/bin/env bash

Profiles::loadProfile() {
  local PROFILE="$1"
  local -a CONFIG_LIST=()
  local ROOT_DEPENDENCY
  checkMissingScripts || exit 1
  # load the profile
  if [[ -z "${PROFILE}" ]]; then
    shift
    CONFIG_LIST=("$@")
    ROOT_DEPENDENCY="your software selection"
  else
    Log::displayInfo "Loading profile '${ROOT_DIR}/profile.${PROFILE}.sh'"
    # shellcheck source=/src/Profiles/profile.default.template
    source "${ROOT_DIR}/profile.${PROFILE}.sh"
    ROOT_DEPENDENCY="profile ${PROFILE}"
  fi
  if [[ ! -v CONFIG_LIST ]]; then
    Log::fatal "Profile ${ROOT_DIR}/profile.${PROFILE}.sh missing variable CONFIG_LIST"
  fi
  if [[ ${#CONFIG_LIST[@]} -eq 0 ]]; then
    Log::fatal "Profile ${ROOT_DIR}/profile.${PROFILE}.sh variable CONFIG_LIST cannot be empty"
  fi

  # remove duplicates from profile preserving order
  mapfile -t CONFIG_LIST < <(
    IFS=$'\n'
    echo "${CONFIG_LIST[*]}" | awk '!x[$0]++'
  )
  if [[ "${SKIP_DEPENDENCIES}" = "0" ]]; then
    CONFIG_LIST=("_Test" "_Upgrade" "MandatorySoftwares" "${CONFIG_LIST[@]}" "_Clean" "_Export")
    # deduce dependencies
    local -a allDepsResult=()
    # shellcheck disable=SC2034
    local -a allDepsResultSeen=()
    Profiles::allDepsRecursive "${ROOT_DEPENDENCY}" "${CONFIG_LIST[@]}" allDepsResult allDepsResultSeen
    CONFIG_LIST=("${allDepsResult[@]}")
  else
    CONFIG_LIST=("${CONFIG_LIST[@]}")
  fi

}
