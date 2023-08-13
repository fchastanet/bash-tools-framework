#!/usr/bin/env bash

# @description remove cache file if too old
# @arg $1 cacheFile:String the file to delete if expiration reached
# @arg $2 expiration:int expiration time in days (eg: 1 means 1 day) (default value: 1)
# @exitcode 1 if cacheFile not provided or empty
# @exitcode 2 if cacheFile targets a directory
# @exitcode * find exit code on error
# @stderr find output on error
Cache::removeCacheFileIfTooOld() {
  local cacheFile expiration
  cacheFile="$1"
  expiration="${2:-1}"

  if [[ -z "${cacheFile}" ]]; then
    return 1
  fi
  if [[ -d "${cacheFile}" ]]; then
    return 2
  fi
  if [[ ! -f "${cacheFile}" ]]; then
    return 0
  fi

  find "${cacheFile}" -depth -maxdepth 1 -type f -mtime "${expiration}" -delete
}
