#!/usr/bin/env bash

# Backup given file in the same directory
# @param {string} $1 the file to backup
# @output messages about backup file location
Backup::file() {
  local file="$1"
  local backupFile
  if [[ -f "${file}" ]]; then
    backupFile="${file}_$(date +"%Y-%m-%d_%H:%M:%S")"
    Log::displayInfo "Backup file '${file}' to ${backupFile}"
    cp "${file}" "${backupFile}"
  fi
}
