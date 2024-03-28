#!/usr/bin/env bash

# @description Backup given directory in the base directory or in BACKUP_DIR directory
# backup directory name is composed by following fields separated by _:
#   - if BACKUP_DIR is not empty then escaped full dirname separated by @
#   - date with format %Y%m%d_%H:%M:%S (Eg: 20240326_14:45:08)
#   - .tgz extension
#
# @arg $1 string the base directory
# @arg $2 string the directory to backup from base directory
#
# @env BACKUP_DIR String variable referencing backup directory
# @env FRAMEWORK_ROOT_DIR String  used to remove this project directory from displayed backup path
# @env SUDO String allows to use custom sudo prefix command
#
# @exitcode 1 if directory to backup does not exist, 0 if everything is OK
# @exitcode 2 on backup failure
#
# @stderr message about where the directory is backed up
# @require Linux::requireTarCommand
Backup::dir() {
  local escapedDirname backupFile
  local fromDir="$1"
  local dirname="$2"

  if [[ ! -d "${fromDir}/${dirname}" ]]; then
    Log::displayError "Backup::dir - directory '${fromDir}/${dirname}' doesn't exist"
    return 1
  fi
  if [[ -z "${BACKUP_DIR:-}" ]]; then
    escapedDirname="$(sed -e 's#^/##; s#/#@#g' <<<"${dirname}")"
    backupFile="${fromDir}/${escapedDirname}-$(date +"%Y%m%d_%H:%M:%S").tgz"
  else
    escapedDirname="$(sed -e 's#^/##; s#/#@#g' <<<"${fromDir}/${dirname}")"
    backupFile="${BACKUP_DIR}/${escapedDirname}-$(date +"%Y%m%d_%H:%M:%S").tgz"
  fi

  Log::displayInfo "Backup directory '${fromDir}/${dirname}' to ${backupFile}"
  if ! ${SUDO:-} tar --same-owner -czf "${backupFile}" "${fromDir}/${dirname}" 2>/dev/null; then
    Log::displayError "cannot backup '${fromDir}/${dirname}'"
    return 2
  fi
}
