#!/usr/bin/env bash

Profiles::allDepsRecursive() {
  local parent="$1"
  shift
  local i
  local addDep=0

  for i in "$@"; do
    if [[ ! -d "${SCRIPTS_DIR}/${i}" ]]; then
      Log::fatal "Dependency ${i} doesn't exist"
    fi
    mapfile -t deps < <(deps "${i}")
    if [[ -z "${allDepsResultSeen[${i}]+exists}" ]]; then
      addDep=1
      allDepsResultSeen["${i}"]='stored'
    fi
    if ((${#deps} > 0)); then
      allDepsRecursive "${i}" "${deps[@]}"
    fi
    if [[ "${addDep}" = "1" ]]; then
      Log::displayInfo "${i} is a dependency of ${parent}"
      allDepsResult+=("${i}")
    fi
    addDep=0
  done
}
