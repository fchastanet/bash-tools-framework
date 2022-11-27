#!/usr/bin/env bash

# installs file to given directory
# @param $1 FROM_DIR - directory to take filename from
# @param $2 TO_DIR - directory in which file will be copied
# @param $3 FILENAME - the filename to copy, the file can specify a subdirectory
#    that will be used relatively in FROM_DIR and TO_DIR
# @param $4 SUCCESS_CALLBACK the callback to call when file is installed successfully
#    by default setUserRights callback is called
#    callback parameters $FROM_FILE $DEST_FILE $@
# @param $5 FAILURE_CALLBACK the callback to call when file installation has failed
#    by default setUserRights callback is called
#    callback parameters $FROM_FILE $DEST_FILE $@
# @param $@ all parameters after 4th will be passed to callback
Install::file() {
  local FROM_DIR="$1"
  local TO_DIR="$2"
  local FILENAME="$3"
  local successCallback=${4:-setUserRights}
  local failureCallback=${5:-unableToCopy}
  ((argsToShift = 3))
  if [[ -n "${4+x}" ]]; then
    ((argsToShift++))
  fi
  if [[ -n "${5+x}" ]]; then
    ((argsToShift++))
  fi
  shift "${argsToShift}"

  if [[ ! -f "${FROM_DIR}/${FILENAME}" || ! -r "${FROM_DIR}/${FILENAME}" ]]; then
    Log::fatal "cannot read source file '${FROM_DIR}/${FILENAME}'"
  fi

  # skip if OVERWRITE_CONFIG_FILES is 0 and target file exists
  if [[ "${OVERWRITE_CONFIG_FILES}" = "0" && -f "${TO_DIR}/${FILENAME}" ]]; then
    Log::displayWarning "File '${TO_DIR}/${FILENAME}' exists - Skip install (because OVERWRITE_CONFIG_FILES=0 in .env file)"
    return 0
  fi

  # skip if CHANGE_WINDOWS_FILES is 0 and target dir is c drive
  if [[ "${CHANGE_WINDOWS_FILES}" = "0" && "${TO_DIR}" =~ ^${BASE_MNT_C} ]]; then
    Log::displayWarning "File '${TO_DIR}/${FILENAME}' - Skip install (because CHANGE_WINDOWS_FILES=0 in .env file)"
    return 0
  fi

  local DEST_FILE="${TO_DIR}/${FILENAME}"
  local DEST_DIR
  DEST_DIR="$(dirname "${DEST_FILE}")"
  if [[ ! -d "${DEST_DIR}" ]]; then
    mkdir -p "${DEST_DIR}"
    chown "${USER_NAME}":"${USER_GROUP}" "${DEST_DIR}"
  fi

  backupFile "${TO_DIR}/${FILENAME}"
  local DEST_FILE="${TO_DIR}/${FILENAME}"
  if cp "${FROM_DIR}/${FILENAME}" "${DEST_FILE}"; then
    ${successCallback} "${FROM_DIR}/${FILENAME}" "${DEST_FILE}" "$@"
    Log::displaySuccess "Installed file '${FROM_DIR#"${ROOT_DIR}/"}/${FILENAME}' to '${DEST_FILE}'"
  else
    ${failureCallback} "${FROM_DIR}" "${FILENAME}" "${DEST_FILE}" "$@"
  fi
}
