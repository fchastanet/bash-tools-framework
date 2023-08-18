#!/usr/bin/env bash

# @description Backup given directory using tar gzipped
#
# @arg $1 string the base directory
# @arg $2 string the directory to backup from base directory
#
# @env BACKUP_DIR String variable referencing backup directory
# @env FRAMEWORK_ROOT_DIR String  used to remove this project directory from displayed backup path
#
# @exitcode 1 if directory to backup does not exist, 0 if everything is OK
# @exitcode 2 on backup failure
#
# @stderr message about where the directory is backed up
# @require Linux::requireTarCommand
Backup::dir() {
  local escapedDirname backupFile
  local fromDir="$1"
  local dirName="$2"

  if [[ -d "${fromDir}/${dirName}" ]]; then
    escapedDirname="$(echo "${fromDir}/${dirName}" | sed -e 's#^/##; s#/#@#g')"
    backupFile="${BACKUP_DIR}/${escapedDirname}-$(date "+%Y%m%d-%H%M%S").tgz"
    Log::displayInfo "Backup directory '${fromDir}/${dirName}' to ${backupFile#"${FRAMEWORK_ROOT_DIR}/"}"
    if ! tar --same-owner -czf "${backupFile}" "${fromDir}/${dirName}" 2>/dev/null; then
      Log::displayError "cannot backup '${fromDir}/${dirName}'"
      return 2
    fi
  else
    return 1
  fi
}
