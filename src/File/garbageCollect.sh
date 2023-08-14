#!/usr/bin/env bash

# @description delete files older than n days in given path
# @warning use this function with caution as it will delete all files in given path without any prompt
# @arg $1 path:String the directory in which files will be deleted or the file to delete
# @arg $2 mtime:String expiration time in days (eg: 1 means 1 day) (default value: 1). Eg: +1 match files that have been accessed at least two days ago (rounding effect)
# @arg $3 maxdepth:int Descend at most levels (a non-negative integer) levels of directories below the starting-points. (default value: 1)
# @exitcode 1 if path not provided or empty
# @exitcode * find command failure code
# @stderr find output on error or diagnostics logs
# @see man find atime
File::garbageCollect() {
  local path="$1"
  local mtime="$2"
  local maxdepth="${3:-1}"

  if [[ -z "${path}" ]]; then
    return 1
  fi

  if [[ ! -e "${path}" ]]; then
    # path already removed
    return 0
  fi

  Log::displayInfo "Garbage collect files older than ${mtime} days in path ${path} with max depth ${maxdepth}"
  find "${path}" -depth -maxdepth "${maxdepth}" -type f -mtime "${mtime}" -print -delete
}
