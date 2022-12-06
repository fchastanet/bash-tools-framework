#!/usr/bin/env bash

# clone the repository if not done yet, else pull it if no change in it
# @param {String} $1 directory in which repository is installed or will be cloned
# @param {String} $2 repository url
# @param {function} $3 callback on successful clone
# @param {function} $4 callback on successful pull
# @param {$@} gitCloneOptions
# @return 0 on successful pulling/cloning, 1 on failure
Git::cloneOrPullIfNoChanges() {
  local dir="$1"
  local repo="$2"
  local cloneCallback=${3:-}
  local pullCallback=${4:-}
  shift 4 || true

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
    git clone "${GIT_CLONE_OPTIONS[@]}" --progress "$@" "${repo}" "${dir}" && (
      # shellcheck disable=SC2086
      if [[ "$(type -t ${cloneCallback})" = "function" ]]; then
        ${cloneCallback} "${dir}"
      fi
    )
  fi
}
