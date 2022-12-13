#!/usr/bin/env bash

# Public: shallow clone a repository at specific commit sha, tag or branch
# or update repo if already exists
#
# **Arguments**:
# * $1 repository
# * $2 Install dir
# * $3 revision commit sha, tag or branch
# * $4 put "FORCE_DELETION" to force directory deletion if directory exists and it's not a git repository (default: 0)
#     USE THIS OPTION WITH CAUTION !!! as the directory will be deleted without any prompt
#
# **Return**:
# * code !=0 if git failure or directory not writable
# * code=1 if destination dir already exists and force option is not 1
Git::shallowClone() {
  local REPO="$1"
  local INSTALL_DIR="$2"
  local REVISION="$3"
  local FORCE_DELETION="${4:-0}"

  if [[ -d "${INSTALL_DIR}/.git" ]]; then
    Log::displayInfo "Repository ${INSTALL_DIR} already installed"
  else
    if [[ -f "${INSTALL_DIR}" || -d "${INSTALL_DIR}" ]]; then
      if [[ "${FORCE_DELETION}" = "FORCE_DELETION" ]]; then
        Log::displayWarning "Removing ${INSTALL_DIR} ..."
        rm -Rf "${INSTALL_DIR}" || exit 1
      else
        Log::displayError "Destination ${INSTALL_DIR} already exists, use force option to automatically delete the destination"
        return 1
      fi
    fi
    (
      Log::displayInfo "Installing ${INSTALL_DIR} ..."
      mkdir -p "${INSTALL_DIR}"
      cd "${INSTALL_DIR}" || exit 1
      git init >&2
      git remote add origin "${REPO}" >&2
    )
  fi
  (
    cd "${INSTALL_DIR}" || exit 1
    git -c advice.detachedHead=false fetch --progress --depth 1 origin "${REVISION}" >&2
    git reset --hard FETCH_HEAD >&2
  )
}
