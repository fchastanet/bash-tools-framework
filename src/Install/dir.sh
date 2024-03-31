#!/usr/bin/env bash

# @description install dir to given directory but backup it before
# @arg $1 fromDir:String the source base directory
# @arg $2 toDir:String the target base directory
# @arg $3 dirName:String the directory relative to fromDir arg that will be copied
# @arg $4 userName:String (optional) (default: ${USERNAME}) the user name that will be used to set target files ownership
# @arg $5 userGroup:String (optional) (default: ${USERNAME}) the group name that will be used to set target files ownership
# @env OVERWRITE_CONFIG_FILES Boolean (default:0) if 1 will overwrite existing directory
# @env CHANGE_WINDOWS_FILES Boolean (default:0) if 1 and target directory is in windows file system, overwrite it
# @env USERNAME (default: root) the user name that will be used to set target files ownership
# @env USERGROUP (default: root) the group name that will be used to set target files ownership
# @env BASE_MNT_C String windows C drive base PATH
# @env FRAMEWORK_ROOT_DIR used to make paths relative to this directory to reduce length of messages
# @env SUDO String allows to use custom sudo prefix command
# @env BACKUP_BEFORE_INSTALL Boolean (default:1) backup directory before installing the dir
# @exitcode 1 if source directory is not readable
# @exitcode 2 if source directory backup failed
# @exitcode 0 if copy successful or OVERWRITE_CONFIG_FILES=0 or
# @exitcode 0 with warning message if OVERWRITE_CONFIG_FILES=0 and target directory exists
# @exitcode 0 with warning message if CHANGE_WINDOWS_FILES=0 and target directory in C drive
# @stderr diagnostics information is displayed, skipped information if OVERWRITE_CONFIG_FILES or CHANGE_WINDOWS_FILES are set to 1
Install::dir() {
  local fromDir="$1"
  local toDir="$2"
  local dirName="$3"
  local userName="${4:-${USERNAME:-root}}"
  local userGroup="${5:-${USERGROUP:-root}}"

  if [[ ! -d "${fromDir}/${dirName}" || ! -r "${fromDir}/${dirName}" ]]; then
    Log::displayError "cannot read source directory '${fromDir}/${dirName}'"
    return 1
  fi

  # skip if OVERWRITE_CONFIG_FILES=0 and target dir exists
  if [[ "${OVERWRITE_CONFIG_FILES:-0}" = "0" && -d "${toDir}/${dirName}" ]]; then
    Log::displayWarning "Directory '${toDir}/${FILENAME}' exists - Skip install "
    return 0
  fi

  # skip if CHANGE_WINDOWS_FILES is 0 and target dir is c drive
  if [[ "${CHANGE_WINDOWS_FILES:-0}" = "0" && "${toDir}" =~ ^${BASE_MNT_C} ]]; then
    Log::displayWarning "Directory '${fromDir}' - Skip install (because CHANGE_WINDOWS_FILES=0 in .env file)"
    return 0
  fi

  if [[ "${BACKUP_BEFORE_INSTALL:-1}" = "1" ]]; then
    Backup::dir "${toDir}" "${dirName}" || return 2
  fi

  local destDir="${toDir}/${dirName}"
  local shortDir="${fromDir#"${FRAMEWORK_ROOT_DIR}/"}/${dirName}"
  Log::displayDebug "Installing directory '${destDir}' from '${shortDir}'"
  (
    ${SUDO:-} mkdir -p "${destDir}"
    cd "${fromDir}/${dirName}" || exit 1
    shopt -s dotglob # * will match hidden files too
    if [[ -z "$(ls -A .)" ]]; then
      Log::displaySkipped "directory '${shortDir}' is empty, no copy needed"
      return 0
    fi
    if ! ${SUDO:-} cp -R -- * "${destDir}"; then
      Log::displayError "unable to copy directory '${shortDir}' to '${destDir}'"
      exit 1
    fi
    if ! ${SUDO:-} chown -R "${userName}":"${userGroup}" "${destDir}"; then
      Log::displayError "unable to change directory '${destDir}' owners"
      exit 1
    fi
    # chown all parent directory with same user
    local fullDir="${fromDir}"
    for parentFolder in ${dirName////$'\n'}; do
      fullDir="${fullDir}/${parentFolder}"
      if ! ${SUDO:-} chown "${userName}":"${userGroup}" "${fullDir}"; then
        Log::displayError "unable to change parent directory '${fullDir}' owners"
        exit 1
      fi
    done
  ) || return 1
  # shellcheck disable=SC2295
  Log::displaySuccess "Installed directory '${destDir}' from '${fromDir#${FRAMEWORK_ROOT_DIR}/}/${dirName}'"
}
