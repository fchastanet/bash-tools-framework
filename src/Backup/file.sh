#!/usr/bin/env bash

# Backup given file in the same directory
# @arg $1 file:string the file to backup
# @stdout messages about backup file location
Backup::file() {
  local file="$1"
  local backupFile
  if [[ -f "${file}" ]]; then
    backupFile="${file}_$(date +"%Y-%m-%d_%H:%M:%S")"
    Log::displayInfo "Backup file '${file}' to ${backupFile}"
    cp "${file}" "${backupFile}"
  fi
}
