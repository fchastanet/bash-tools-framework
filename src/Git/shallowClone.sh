#!/usr/bin/env bash

# @description shallow clone a repository at specific commit sha, tag or branch
# or update repo if already exists
#
# @warning **USE THIS FORCE_DELETION ARGUMENT WITH CAUTION !!!** as the directory will be deleted without any prompt
#
# @arg $1 repository:String
# @arg $2 installDir:String Install dir
# @arg $3 revision:String commit sha, tag or branch
# @arg $4 forceDeletion:Boolean (optional) put "FORCE_DELETION" to force directory deletion if directory exists and it's not a git repository (default: 0)
#
# @exitcode !=0 if git failure or directory not writable
# @exitcode 1 if destination dir already exists and force option is not 1
# @stderr display verbose status of the command execution
Git::shallowClone() {
  local repository="$1"
  local installDir="$2"
  local revision="$3"
  local forceDeletion="${4:-0}"

  if [[ -d "${installDir}/.git" ]]; then
    Log::displayInfo "Repository ${installDir} already installed"
  else
    if [[ -f "${installDir}" || -d "${installDir}" ]]; then
      if [[ "${forceDeletion}" = "FORCE_DELETION" ]]; then
        Log::displayWarning "Removing ${installDir} ..."
        rm -Rf "${installDir}" || exit 1
      else
        Log::displayError "Destination ${installDir} already exists, use force option to automatically delete the destination"
        return 1
      fi
    fi
    (
      Log::displayInfo "Installing ${installDir} ..."
      mkdir -p "${installDir}"
      cd "${installDir}" || exit 1
      git init >&2
      git remote add origin "${repository}" >&2
    )
  fi
  (
    cd "${installDir}" || exit 1
    git -c advice.detachedHead=false fetch --progress --depth 1 origin "${revision}" >&2
    git reset --hard FETCH_HEAD >&2
  )
}
