#!/usr/bin/env bash

# @description delete files older than n days
#
# @arg $1 path:String
# @arg $2 mtime:String modification time. Eg: +1 match files that have been accessed at least two days ago (rounding effect)
# @see man find atime
#
# @exitcode 1 if the command failed
File::garbageCollect() {
  local path="$1"
  local mtime="$2"
  local maxdepth="${3:-1}"

  Log::displayInfo "Garbage collect files older than ${mtime} days in directory ${path}"
  find "${path}" -maxdepth "${maxdepth}" -type f -mtime "${mtime}" -print -delete
}
