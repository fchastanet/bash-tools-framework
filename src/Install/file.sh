#!/usr/bin/env bash

# @description installs file to given directory
#
# callbacks parameters `${fromFile} ${targetFile} $@`
# @arg $1 fromFile - original file to copy
# @arg $2 targetFile - target file
# @arg $3 successCallback:Function the callback to call when file is installed successfully, by default setUserRights callback is called
# @arg $4 failureCallback:Function the callback to call when file installation has failed, by default setUserRights callback is called
# @arg $@ callbacksParams:String[] all parameters after 4th will be passed to callback
# @exitcode 1 if fromFile is not readable
# @exitcode 2 if backup file failure
# @exitcode 0 on success or if OVERWRITE_CONFIG_FILES=0
# @exitcode 0 on success or if CHANGE_WINDOWS_FILES=0 and target file is a windows file
# @env OVERWRITE_CONFIG_FILES
# @env CHANGE_WINDOWS_FILES
# @env USER_NAME
# @env USER_GROUP
# @env BASE_MNT_C
# @env FRAMEWORK_ROOT_DIR
Install::file() {
  local fromFile="$1"
  local targetFile="$2"
  shift 2 || true
  local successCallback=${1:-Install::setUserRightsCallback}
  shift || true
  local failureCallback=${1:-Install::unableToCopyCallback}
  shift || true

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
    mkdir -p "${targetDir}"
    chown "${USER_NAME}":"${USER_GROUP}" "${targetDir}"
  fi
  local fromDir
  fromDir="$(dirname "${fromFile}")"
  local fromFilename
  fromFilename="$(basename "${fromFile}")"

  Backup::file "${targetFile}" || return 2

  if cp "${fromFile}" "${targetFile}"; then
    ${successCallback} "${fromFile}" "${targetFile}" "$@"
    Log::displaySuccess "Installed file '${fromDir#"${FRAMEWORK_ROOT_DIR}/"}/${fromFilename}' to '${targetFile}'"
  else
    ${failureCallback} "${fromDir}" "${fromFilename}" "${targetFile}" "$@"
  fi
}
