#!/usr/bin/env bash

# pull the repository if no change in it
# @return 0 on successful pulling, 1 on failure or no pull needed
Git::pullIfNoChanges() {
  local dir="$1"
  if [[ -d "${dir}/.git" ]]; then
    (
      cd "${dir}"
      git update-index --refresh
      if git diff-index --quiet HEAD --; then
        Log::displayInfo "Pull git repository '${dir}' as no changes detected"
        git pull --progress
        return 0
      else
        Log::displayWarning "Pulling git repository '${dir}' avoided as changes detected"
      fi
    ) && return 0
  fi
  return 1
}
