#!/usr/bin/env bash

# @description install dir to given directory but backup it before
# @arg $1 fromDir:String the source base directory
# @arg $2 toDir:String the target base directory
# @env OVERWRITE_CONFIG_FILES Boolean (default:0) if 1 will overwrite existing files
# @env CHANGE_WINDOWS_FILES Boolean (default:0) if 1 and target directory is in windows file system, overwrite it
# @env USERNAME (default: ${USERNAME} if SUDO empty else root) the user name that will be used to set target files ownership
# @env USERGROUP (default: ${USERGROUP} if SUDO empty else root) the group name that will be used to set target files ownership
# @env BASE_MNT_C String windows C drive base PATH
# @env PRETTY_ROOT_DIR used to make paths relative to this directory to reduce length of messages
# @env SUDO String allows to use custom sudo prefix command
# @env BACKUP_BEFORE_INSTALL Boolean (default:1) backup directory before installing the dir
# @exitcode 1 if source directory is not readable
# @exitcode 2 if error during structure replication
# @exitcode 2 if error during file copy
# @exitcode 0 if copy successful
# @exitcode 0 with warning message if CHANGE_WINDOWS_FILES=0 and target directory in C drive
# @stderr diagnostics information is displayed, skipped information if OVERWRITE_CONFIG_FILES or CHANGE_WINDOWS_FILES are set to 1
Install::structure() {
  local fromDir="$1"
  local toDir="$2"
  local userName="root"
  local userGroup="root"
  if [[ -z "${SUDO:-}" ]]; then
    userName="${USERNAME:-root}"
    userGroup="${USERGROUP:-root}"
  fi

  if [[ ! -d "${fromDir}" || ! -r "${fromDir}" ]]; then
    Log::displayError "Install::structure - cannot read source directory '${fromDir}'"
    return 1
  fi

  # skip if CHANGE_WINDOWS_FILES is 0 and target dir is c drive
  if [[ "${CHANGE_WINDOWS_FILES:-0}" = "0" && "${toDir}" =~ ^${BASE_MNT_C:-/mnt/c} ]]; then
    Log::displayWarning "Install::structure - Directory '${fromDir}' - Skip install (because CHANGE_WINDOWS_FILES=0 in .env file)"
    return 0
  fi

  # first replicate directory structure
  # shellcheck disable=SC2317
  createStructure() {
    local dir="$1"
    if ! ${SUDO} test -d "${dir}"; then
      if ! ${SUDO:-} mkdir -p "${dir}"; then
        Log::displayError "Install::structure - impossible to create directory '${dir}'"
        exit 1
      fi
    fi

    if ! ${SUDO:-} chown "${userName}":"${userGroup}" "${dir}"; then
      Log::displayError "Install::structure - impossible to update directory owner '${dir}' with ${userName}:${userGroup}"
      exit 1
    fi
  }
  local dir

  (
    local dir
    shopt -s lastpipe
    # -links 2 allows to exclude empty directories
    # %P get file without initial directory
    ${SUDO:-} find "${fromDir}" -depth -type d -links 2 -printf "%P\0" |
      while read -rd '' dir; do
        if ! createStructure "${toDir}/${dir}"; then
          # error already reported by createStructure
          exit 1
        fi
      done || {
      if [[ "${PIPESTATUS[0]}" != "0" ]]; then
        Log::displayError "Install::structure - replicated directory structure - find directories on '${fromDir}' resulted in an error"
        exit 2
      fi
    }
  ) || return 2

  # for each file, copy it
  (
    local file
    shopt -s lastpipe
    ${SUDO:-} find "${fromDir}" -depth -type f -printf "%P\0" |
      while read -rd '' file; do
        if ! Install::file "${fromDir}/${file}" "${toDir}/${file}"; then
          # error already reported by Install::file
          exit 1
        fi
      done || {
      if [[ "${PIPESTATUS[0]}" != "0" ]]; then
        Log::displayError "Install::structure - replicated file structure - find files on '${fromDir}' resulted in an error"
        exit 2
      fi
    }
  ) || return 3

  # shellcheck disable=SC2295
  Log::displaySuccess "Installed directory '${toDir#${PRETTY_ROOT_DIR}/}' from '${fromDir#${PRETTY_ROOT_DIR}/}'"
}
