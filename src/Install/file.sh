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
# @exitcode 0 on success or if OVERWRITE_CONFIG_FILES=0
# @exitcode 0 on success or if CHANGE_WINDOWS_FILES=0 and target file is a windows file
# @env OVERWRITE_CONFIG_FILES Boolean (default:0) if 1 will overwrite existing directory
# @env CHANGE_WINDOWS_FILES Boolean (default:0) if 1 and target file is in windows file system, overwrite it
# @env USERNAME (default: root) the user name that will be used to set target files ownership
# @env USERGROUP (default: root) the group name that will be used to set target files ownership
# @env BASE_MNT_C String windows C drive base PATH
# @env FRAMEWORK_ROOT_DIR used to make paths relative to this directory to reduce length of messages
# @env SUDO_USER String the user to use as sudoer
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

  local targetDir
  targetDir="$(dirname "${targetFile}")"
  if [[ ! -d "${targetDir}" ]]; then
    ${SUDO} mkdir -p "${targetDir}"
    ${SUDO} chown "${userName}":"${userGroup}" "${targetDir}"
  fi
  local fromDir
  fromDir="$(dirname "${fromFile}")"
  local fromFilename
  fromFilename="$(basename "${fromFile}")"

  Backup::file "${targetFile}" || return 2

  if ${SUDO} cp "${fromFile}" "${targetFile}"; then
    ${successCallback} "${fromFile}" "${targetFile}" "$@"
    Log::displaySuccess "Installed file '${fromDir#"${FRAMEWORK_ROOT_DIR}/"}/${fromFilename}' to '${targetFile}'"
  else
    ${failureCallback} "${fromDir}" "${fromFilename}" "${targetFile}" "$@"
  fi
}
