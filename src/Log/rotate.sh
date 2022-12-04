#!/usr/bin/env bash

# To be called before logging in the log file
# @param $1 log file name
# @param $2 maximum number of log files
Log::rotate() {
  local FILENAME="$1"
  local MAX_LOG="${2:-5}"
  for i in $(seq $((MAX_LOG - 1)) -1 1); do
    Log::displayInfo "Log rotation ${FILENAME}.${i} to ${FILENAME}.$((i + 1))"
    mv "${FILENAME}."{"${i}","$((i + 1))"} &>/dev/null || true
  done
  if mv "${FILENAME}" "${FILENAME}.1" &>/dev/null; then
    Log::displayInfo "Log rotation ${FILENAME} to ${FILENAME}.1"
  fi
}
