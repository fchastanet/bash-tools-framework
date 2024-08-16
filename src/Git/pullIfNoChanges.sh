#!/usr/bin/env bash

# @description pull git directory only if no change has been detected
# @arg $1 dir:String the git directory to pull
# @exitcode 0 on successful pulling
# @exitcode 1 on any other failure
# @exitcode 2 changes detected, pull avoided
# @exitcode 3 not a git directory
# @exitcode 4 not able to update index
# @exitcode 5 not a branch, pull avoided
# @stderr diagnostics information is displayed
# @env SUDO String allows to use custom sudo prefix command
# @require Git::requireGitCommand
Git::pullIfNoChanges() {
  local dir="$1"
  if [[ ! -d "${dir}/.git" ]]; then
    return 3
  fi
  (
    cd "${dir}" || return 3
    if ! ${SUDO:-} git update-index --refresh &>/dev/null; then
      Log::displayWarning "Impossible to update git index of '${dir}' - check if you have modified file"
      return 4
    fi
    if ! ${SUDO:-} git diff-index --quiet HEAD --; then
      Log::displayWarning "Pulling git repository '${dir}' avoided as changes detected"
      return 2
    fi
    if ! ${SUDO:-} git symbolic-ref -q HEAD; then
      Log::displayWarning "Pulling git repository '${dir}' avoided as you are not on a branch"
      return 5
    fi
    Log::displayInfo "Pull git repository '${dir}' as no changes detected"
    ${SUDO:-} git pull --progress
  )
}
