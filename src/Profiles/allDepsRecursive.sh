#!/usr/bin/env bash

declare -Ag allDepsResultSeen=()
declare -ag allDepsResult=()

Profiles::allDepsRecursive() {
  local scriptsDir="$1"
  local parent="$2"
  shift 2 || true
  local i
  local addDep=0
  local -a deps=()
  local -a newDeps

  for i in "$@"; do
    if [[ "${allDepsResultSeen["${i}"]}" = 'stored' ]]; then
      continue
    fi
    if [[ ! -f "${scriptsDir}/${i}.sh" ]]; then
      Log::fatal "Dependency ${i} doesn't exist"
    fi
    # shellcheck source=/src/Profiles/testsData/lintDefinitions/OK/Install1.sh
    source "${scriptsDir}/${i}.sh"

    if [[ "$(type -t "installScripts_${i}_dependencies")" != "function" ]]; then
      Log::displaySkipped "${scriptsDir}/${i}.sh does not define the function installScripts_${i}_dependencies"
      continue
    fi
    if [[ -z "${allDepsResultSeen[${i}]+exists}" ]]; then
      addDep=1
      allDepsResultSeen["${i}"]='stored'
    fi
    readarray -t newDeps < <("installScripts_${i}_dependencies")
    deps+=("${newDeps[@]}")
    # remove duplicates from deps preserving order
    mapfile -t deps < <(
      IFS=$'\n'
      echo "${deps[@]}" | awk '!x[$0]++'
    )
    if ((${#newDeps} > 0)); then
      Profiles::allDepsRecursive "${scriptsDir}" "${i}" "${newDeps[@]}"
    fi
    if [[ "${addDep}" = "1" ]]; then
      Log::displayInfo "${i} is a dependency of ${parent}"
      allDepsResult+=("${i}")
    fi
    addDep=0
  done
}
