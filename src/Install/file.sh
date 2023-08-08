#!/usr/bin/env bash

# installs file to given directory
# @param $1 fromFile - original file to copy
# @param $2 targetFile - target file
# @param $3 SUCCESS_CALLBACK the callback to call when file is installed successfully
#    by default setUserRights callback is called
#    callback parameters ${fromFile} ${targetFile} $@
# @param $4 FAILURE_CALLBACK the callback to call when file installation has failed
#    by default setUserRights callback is called
#    callback parameters ${fromFile} ${targetFile} $@
# @param $@ all parameters after 4th will be passed to callback
# @return 1 if fromFile is not readable
# @return 2 if backup file failure
# @return 0 on success or if OVERWRITE_CONFIG_FILES=0
# @return 0 on success or if CHANGE_WINDOWS_FILES=0 and target file is a windows file
# @environment OVERWRITE_CONFIG_FILES
# @environment CHANGE_WINDOWS_FILES
# @environment USER_NAME
# @environment USER_GROUP
# @environment BASE_MNT_C
# @environment FRAMEWORK_ROOT_DIR
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
