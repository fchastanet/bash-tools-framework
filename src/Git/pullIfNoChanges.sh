#!/usr/bin/env bash

# @description pull git directory only if no change has been detected
# @arg $1 dir:String the git directory to pull
# @exitcode 0 on successful pulling
# @exitcode 1 on any other failure
# @exitcode 2 changes detected, pull avoided
# @exitcode 3 not a git directory
# @exitcode 4 not able to update index
# @stderr diagnostics information is displayed
# @require Git::requireGitCommand
Git::pullIfNoChanges() {
  local dir="$1"
  if [[ ! -d "${dir}/.git" ]]; then
    return 3
  fi
  (
    cd "${dir}" || exit 3
    git update-index --refresh &>/dev/null || exit 4
    if ! git diff-index --quiet HEAD --; then
      Log::displayWarning "Pulling git repository '${dir}' avoided as changes detected"
      exit 2
    fi
    Log::displayInfo "Pull git repository '${dir}' as no changes detected"
    git pull --progress
  )
}
