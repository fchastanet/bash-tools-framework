#!/usr/bin/env bash

# @description Backup given file in the same directory or in BACKUP_DIR directory
# backup file name is composed by following fields separated by -:
#   - if BACKUP_DIR is not empty then escaped dirname separated by @
#   - filename(without path)
#   - date with format %Y%m%d_%H:%M:%S (Eg: 20240326_14:45:08)
# @arg $1 file:String the file to backup
# @stderr messages about backup file location
# @env SUDO String allows to use custom sudo prefix command
# @env BACKUP_DIR if not set backup the file in the same directory as original file
# @exitcode 1 on copy failure
Backup::file() {
  local file="$1"
  local backupFile dirname escapedDirname
  if [[ -f "${file}" ]]; then
    dirname="$(dirname "${file}")"
    escapedDirname="$(sed -e 's#^/##; s#/#@#g' <<<"${dirname}")"
    if [[ -z "${BACKUP_DIR:-}" ]]; then
      backupFile="${dirname}/$(basename "${file}")-$(date +"%Y%m%d_%H:%M:%S")"
    else
      backupFile="${BACKUP_DIR}/${escapedDirname}@$(basename "${file}")-$(date +"%Y%m%d_%H:%M:%S")"
    fi
    Log::displayInfo "Backup file '${file}' to ${backupFile}"
    ${SUDO:-} cp "${file}" "${backupFile}"
  fi
}
