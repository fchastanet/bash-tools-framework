#!/usr/bin/env bash

# @description To be called before logging in the log file
# @arg $1 file:string log file name
# @arg $2 maxLogFilesCount:int maximum number of log files
Log::rotate() {
  local file="$1"
  local maxLogFilesCount="${2:-5}"

  if [[ ! -f "${file}" ]]; then
    Log::displayDebug "Log file ${file} doesn't exist yet"
    return 0
  fi
  local i
  for ((i = maxLogFilesCount - 1; i > 0; i--)); do
    Log::displayInfo "Log rotation ${file}.${i} to ${file}.$((i + 1))"
    mv "${file}."{"${i}","$((i + 1))"} &>/dev/null || true
  done
  if cp "${file}" "${file}.1" &>/dev/null; then
    echo >"${file}" # reset log file
    Log::displayInfo "Log rotation ${file} to ${file}.1"
  fi
}
