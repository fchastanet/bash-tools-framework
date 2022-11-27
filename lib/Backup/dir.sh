#!/usr/bin/env bash

# Backup given directory using tar gzipped
# @param {string} $1 the base directory
# @param {string} $2 the directory to backup from base directory
# @global BACKUP_DIR variable referencing backup directory
# @global ROOT_DIR used to remove this project directory from displayed backup path
# @return 1 if directory to backup does not exist, 0 if everything is OK
# @return 2 on backup failure
# @output message about where the directory is backed up
Backup::dir() {
  local FROM_DIR="$1"
  local DIRNAME="$2"

  if [[ -d "${FROM_DIR}/${DIRNAME}" ]]; then
    local ESCAPED_DIRNAME
    local BACKUP_FILE
    ESCAPED_DIRNAME="$(echo "${FROM_DIR}/${DIRNAME}" | sed -e 's#^/##; s#/#@#g')"
    BACKUP_FILE="${BACKUP_DIR}/${ESCAPED_DIRNAME}-$(date "+%Y%m%d-%H%M%S").tgz"
    Log::displayInfo "Backup directory '${FROM_DIR}/${DIRNAME}' to ${BACKUP_FILE#"${ROOT_DIR}/"}"
    if ! tar --same-owner -czf "${BACKUP_FILE}" "${FROM_DIR}/${DIRNAME}" 2>/dev/null; then
      Log::error "cannot backup '${FROM_DIR}/${DIRNAME}'"
      return 2
    fi
  else
    return 1
  fi
}
