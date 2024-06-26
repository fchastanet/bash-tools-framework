#!/usr/bin/env bash

# @description installs file to given directory
#
# callbacks parameters `${fromFile} ${targetFile} $@`
# @arg $1 fromFile - original file to copy
# @arg $2 targetFile - target file
# @arg $3 userName:String (optional) (default: ${USERNAME}) the user name that will be used to set target files ownership
# @arg $4 userGroup:String (optional) (default: ${USERNAME}) the group name that will be used to set target files ownership
# @arg $5 successCallback:Function the callback to call when file is installed successfully, by default setUserRights callback is called
# @arg $6 failureCallback:Function the callback to call when file installation has failed, by default unableToCopyCallback callback is called
# @arg $@ callbacksParams:String[] additional parameters passed to callbacks
# @exitcode 1 if fromFile is not readable
# @exitcode 2 if backup file failure
# @exitcode 3 if copy failure
# @exitcode 0 on success or if OVERWRITE_CONFIG_FILES=0
# @exitcode 0 on success or if CHANGE_WINDOWS_FILES=0 and target file is a windows file
# @env OVERWRITE_CONFIG_FILES Boolean (default:0) if 1 will overwrite existing directory
# @env CHANGE_WINDOWS_FILES Boolean (default:0) if 1 and target file is in windows file system, overwrite it
# @env USERNAME (default: root) the user name that will be used to set target files ownership
# @env USERGROUP (default: root) the group name that will be used to set target files ownership
# @env BASE_MNT_C String windows C drive base PATH
# @env FRAMEWORK_ROOT_DIR used to make paths relative to this directory to reduce length of messages
# @env SUDO String allows to use custom sudo prefix command
# @env BACKUP_BEFORE_INSTALL Boolean (default: 1) backup file before installing the file
Install::file() {
  local fromFile="$1"
  local targetFile="$2"
  local userName="${3:-${USERNAME:-root}}"
  local userGroup="${4:-${USERGROUP:-root}}"
  local successCallback=${5:-Install::setUserRightsCallback}
  local failureCallback=${6:-Install::unableToCopyCallback}
  shift 6 || true

  if [[ ! -f "${fromFile}" || ! -r "${fromFile}" ]]; then
    Log::displayError "cannot read source file '${fromFile}'"
    return 1
  fi

  # skip if OVERWRITE_CONFIG_FILES is 0 and target file exists
  if [[ "${OVERWRITE_CONFIG_FILES}" = "0" && -f "${targetFile}" ]]; then
    Log::displayWarning "File '${targetFile}' exists - Skip install (because OVERWRITE_CONFIG_FILES=0 in .env file)"
    return 0
  fi

  # skip if CHANGE_WINDOWS_FILES is 0 and target dir is c drive
  if [[ "${CHANGE_WINDOWS_FILES}" = "0" && "${targetFile}" =~ ^${BASE_MNT_C} ]]; then
    Log::displayWarning "File '${targetFile}' - Skip install (because CHANGE_WINDOWS_FILES=0 in .env file)"
    return 0
  fi

  local targetDir="${targetFile%/*}"
  if ! ${SUDO} test -d "${targetDir}"; then
    ${SUDO:-} mkdir -p "${targetDir}"
    ${SUDO:-} chown "${userName}":"${userGroup}" "${targetDir}"
  fi
  local fromDir="${fromFile%/*}"
  local fromFilename="${fromFile##*/}"

  local prettyFromDir
  # shellcheck disable=SC2295
  prettyFromDir="${fromDir#${PRETTY_ROOT_DIR:-${FRAMEWORK_ROOT_DIR}}/}"
  if diff -q "${fromFile}" "${targetFile}" &>/dev/null; then
    Log::displayStatus "No changes detected. No need to update '${targetFile}' from '${prettyFromDir}/${fromFilename}'"
    return 0
  fi

  if [[ "${BACKUP_BEFORE_INSTALL:-1}" = "1" ]]; then
    Backup::file "${targetFile}" || return 2
  fi

  if ${SUDO:-} cp "${fromFile}" "${targetFile}"; then
    # shellcheck disable=SC2295
    Log::displaySuccess "Installed file '${targetFile}' from '${prettyFromDir}/${fromFilename}'"
    ${successCallback} "${fromFile}" "${targetFile}" "${userName}" "${userGroup}" "${prettyFromDir}" "${fromFilename}"
  else
    # shellcheck disable=SC2295
    Log::displayError "unable to copy file '${targetFile}' from '${fromDir#${FRAMEWORK_ROOT_DIR}/}/${fromFilename}'"
    ${failureCallback} "${fromFile}" "${targetFile}" "${userName}" "${userGroup}" "${prettyFromDir}" "${fromFilename}"
    return 3
  fi
}
