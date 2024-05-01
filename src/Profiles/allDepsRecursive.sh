#!/usr/bin/env bash

declare -Ag allDepsResultSeen=()
declare -ag allDepsResult=()

# @description get recursively all the dependencies of each config from configs arg
#
# The parent argument must be set to "your software selection" when you call it,
# then the value will change when this function will be called recursively with the
# parent dependency
#
# Algorithm
#   For each config in configs
#     - load config definition
#     - mark this config as seen to avoid to recompute it later, in the case where another
#       definition depends on it
#     - call installScripts_${config}_dependencies function if exists (skipped if not)
#     - add these new dependencies if any to current dependencies list
#     - call recursively Profiles::allDepsRecursive with these dependencies
#     - add in allDepsResult the current config if it was not seen yet
#   This has constructed a tree with the most deep dependency present in the first items
#
# @warning allDepsResultSeen and allDepsResult global variables have to reset to empty array every time you call this function
#
# @arg $1 scriptsDir:String base directory where dependencies can be retrieved
# @arg $2 parent:String set to "your software selection" when you call it
# @arg $@ configs:String[] list of configurations to load, each config can depend on an other one
# @exitcode 1 if one of the dependency cannot be found
# @exitcode 2 if error while loading one of the dependency definition
# @exitcode 3 if error while calling dependencies function of the dependency's definition
# @set allDepsResultSeen String[] list of dependencies already seen
# @set allDepsResult String[] the final list of dependencies sorted by the most to less dependent
# @stderr diagnostics information is displayed
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
      Log::displayError "Dependency ${i} doesn't exist"
      return 1
    fi
    # shellcheck source=/src/Profiles/testsData/lintDefinitions/OK/Install1.sh
    if ! source "${scriptsDir}/${i}.sh"; then
      Log::displayError "Dependency ${i} cannot be loaded"
      return 2
    fi

    if [[ "$(type -t "installScripts_${i}_dependencies")" != "function" ]]; then
      Log::displaySkipped "${scriptsDir}/${i}.sh does not define the function installScripts_${i}_dependencies"
      continue
    fi
    if [[ -z "${allDepsResultSeen[${i}]+exists}" ]]; then
      addDep=1
      allDepsResultSeen["${i}"]='stored'
    fi
    if ! readarray -t newDeps < <("installScripts_${i}_dependencies"); then
      Log::displayError "Dependency ${i} - installScripts_${i}_dependencies failure"
      return 3
    fi
    deps+=("${newDeps[@]}")
    # remove duplicates from deps preserving order
    mapfile -t deps < <(
      IFS=$'\n'
      echo "${deps[@]}" | Filters::uniqUnsorted
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
