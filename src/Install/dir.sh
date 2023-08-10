#!/usr/bin/env bash

# install dir to given directory
Install::dir() {
  local FROM_DIR="$1"
  local TO_DIR="$2"
  local DIRNAME="$3"
  local USER_NAME="${4:-${USERNAME:-root}}"
  local USER_GROUP="${5:-${USERGROUP:-root}}"

  if [[ ! -d "${FROM_DIR}/${DIRNAME}" || ! -r "${FROM_DIR}/${DIRNAME}" ]]; then
    Log::fatal "cannot read source directory '${FROM_DIR}/${DIRNAME}'"
  fi

  # skip if OVERWRITE_CONFIG_FILES=0 and target dir exists
  if [[ "${OVERWRITE_CONFIG_FILES}" = "0" && -d "${TO_DIR}/${DIRNAME}" ]]; then
    Log::displayWarning "Directory '${TO_DIR}/${FILENAME}' exists - Skip install "
    return 0
  fi

  # skip if CHANGE_WINDOWS_FILES is 0 and target dir is c drive
  if [[ "${CHANGE_WINDOWS_FILES}" = "0" && "${TO_DIR}" =~ ^${BASE_MNT_C} ]]; then
    Log::displayWarning "Directory '${FROM_DIR}' - Skip install (because CHANGE_WINDOWS_FILES=0 in .env file)"
    return 0
  fi

  backupDir "${TO_DIR}" "${DIRNAME}"

  local DEST_DIR="${TO_DIR}/${DIRNAME}"
  Log::displayDebug "Install directory '${FROM_DIR#"${FRAMEWORK_ROOT_DIR}/"}/${DIRNAME}' to '${DEST_DIR}'"
  (
    mkdir -p "${DEST_DIR}"
    cd "${FROM_DIR}/${DIRNAME}" || exit 1
    shopt -s dotglob # * will match hidden files too
    cp -R -- * "${DEST_DIR}" ||
      Log::fatal "unable to copy directory '${FROM_DIR#"${FRAMEWORK_ROOT_DIR}/"}/${DIRNAME}' to '${DEST_DIR}'"
    chown -R "${USER_NAME}":"${USER_GROUP}" "${DEST_DIR}"
    # chown all parent directory with same user
    local fullDir="${FROM_DIR}"
    for parentFolder in ${DIRNAME////$'\n'}; do
      fullDir="${fullDir}/${parentFolder}"
      chown "${USER_NAME}":"${USER_GROUP}" "${fullDir}"
    done
  )
  Log::displaySuccess "Installed directory '${FROM_DIR#"${FRAMEWORK_ROOT_DIR}/"}/${DIRNAME}' to '${DEST_DIR}')"
}
