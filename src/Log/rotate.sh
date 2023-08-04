#!/usr/bin/env bash

# To be called before logging in the log file
# @param {string} file $1 log file name
# @param {int} maxLogFilesCount $2 maximum number of log files
Log::rotate() {
  local file="$1"
  local maxLogFilesCount="${2:-5}"

  if [[ ! -f "${file}" ]]; then
    Log::displaySkipped "Log file ${file} doesn't exist yet"
    return 0
  fi
  for i in $(seq $((maxLogFilesCount - 1)) -1 1); do
    Log::displayInfo "Log rotation ${file}.${i} to ${file}.$((i + 1))"
    mv "${file}."{"${i}","$((i + 1))"} &>/dev/null || true
  done
  if cp "${file}" "${file}.1" &>/dev/null; then
    echo >"${file}" # reset log file
    Log::displayInfo "Log rotation ${file} to ${file}.1"
  fi
}
