#!/usr/bin/env bash

# @description clone the repository if not done yet, else pull it if no change in it
# @arg $1 dir:String directory in which repository is installed or will be cloned
# @arg $2 repo:String repository url
# @arg $3 cloneCallback:Function callback on successful clone
# @arg $4 pullCallback:Function callback on successful pull
# @env GIT_CLONE_OPTIONS:String additional options to pass to git clone command
# @env SUDO String allows to use custom sudo prefix command
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
    if ! Git::pullIfNoChanges "${dir}"; then
      return 1
    fi
    # shellcheck disable=SC2086
    if [[ "$(type -t ${pullCallback})" = "function" ]]; then
      ${pullCallback} "${dir}"
    fi
  else
    Log::displayInfo "cloning ${repo} ..."
    ${SUDO:-} mkdir -p "$(${SUDO:-} dirname "${dir}")"
    # shellcheck disable=SC2086,SC2248
    if ${SUDO:-} git clone ${GIT_CLONE_OPTIONS} --progress "$@" "${repo}" "${dir}"; then
      # shellcheck disable=SC2086
      if [[ "$(type -t ${cloneCallback})" = "function" ]]; then
        ${cloneCallback} "${dir}"
      fi
    else
      Log::displayError "Cloning '${repo}' on '${dir}' failed"
      return 1
    fi
  fi
}
