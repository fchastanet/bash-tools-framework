#!/usr/bin/env bash

# Backup given file in the same directory
# @param {string} $1 the file to backup
# @param {string} $2 if 'sudo' then copy file using sudo
#                  default or other value normal copy
# @output messages about backup file location
Backup::file() {
  local file, sudo, backupFile
  file="$1"
  sudo="${2:-0}"
  if [[ -f "${file}" ]]; then
    backupFile="${file}_$(date +"%Y-%m-%d_%H:%M:%S")"
    Log::displayInfo "Backup file '${file}' to ${backupFile}"
    if [[ "${sudo}" = "sudo" ]]; then
      sudo cp "${file}" "${backupFile}"
    fi
  fi
}
