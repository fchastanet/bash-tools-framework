#!/usr/bin/env bash

# @description clone the repository if not done yet, else pull it if no change in it
# @arg $1 dir:String directory in which repository is installed or will be cloned
# @arg $2 repo:String repository url
# @arg $3 cloneCallback:Function callback on successful clone
# @arg $4 pullCallback:Function callback on successful pull
# @env GIT_CLONE_OPTIONS:String additional options to pass to git clone command
# @exitcode 0 on successful pulling/cloning, 1 on failure
Git::cloneOrPullIfNoChanges() {
  local dir="$1"
  shift || true
  local repo="$1"
  shift || true
  local cloneCallback=${1:-}
  shift || true
  local pullCallback=${1:-}
  shift || true

  if [[ -d "${dir}/.git" ]]; then
    Git::pullIfNoChanges "${dir}" && (
      # shellcheck disable=SC2086
      if [[ "$(type -t ${pullCallback})" = "function" ]]; then
        ${pullCallback} "${dir}"
      fi
    )
  else
    Log::displayInfo "cloning ${repo} ..."
    mkdir -p "$(dirname "${dir}")"
    # shellcheck disable=SC2086,SC2248
    git clone ${GIT_CLONE_OPTIONS} --progress "$@" "${repo}" "${dir}" && (
      # shellcheck disable=SC2086
      if [[ "$(type -t ${cloneCallback})" = "function" ]]; then
        ${cloneCallback} "${dir}"
      fi
    )
  fi
}
