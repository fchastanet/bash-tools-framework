#!/usr/bin/env bash

# @description Backup given file in the same directory appending _ followed by the current date
# @arg $1 file:String the file to backup
# @stderr messages about backup file location
# @exitcode 1 on copy failure
Backup::file() {
  local file="$1"
  local backupFile
  if [[ -f "${file}" ]]; then
    backupFile="${file}_$(date +"%Y-%m-%d_%H:%M:%S")"
    Log::displayInfo "Backup file '${file}' to ${backupFile}"
    cp "${file}" "${backupFile}"
  fi
}
