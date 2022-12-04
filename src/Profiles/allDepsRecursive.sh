#!/usr/bin/env bash

Profiles::allDepsRecursive() {
  local parent="$1"
  local -an allDepsResult=$2
  local -an allDepsResultSeen=$3
  shift 3
  local i
  local addDep=0
  local -a deps

  for i in "$@"; do
    if [[ ! -d "${SCRIPTS_DIR}/${i}" ]]; then
      Log::fatal "Dependency ${i} doesn't exist"
    fi
    while IFS= read -r line; do
      deps+=("${line}")
    done < <(Profiles::deps "${i}" allDepsResultSeen | grep '^\s*$')
    if [[ -z "${allDepsResultSeen[${i}]+exists}" ]]; then
      addDep=1
      allDepsResultSeen["${i}"]='stored'
    fi
    if ((${#deps} > 0)); then
      Profiles::allDepsRecursive "${i}" allDepsResult allDepsResultSeen "${deps[@]}"
    fi
    if [[ "${addDep}" = "1" ]]; then
      Log::displayInfo "${i} is a dependency of ${parent}"
      allDepsResult+=("${i}")
    fi
    addDep=0
  done
}
