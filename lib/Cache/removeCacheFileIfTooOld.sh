#!/usr/bin/env bash

Cache::removeCacheFileIfTooOld() {
  local cacheFile="$1"
  local expiration="$2"

  if [[ -n "$(find "${cacheFile}" -mtime "${expiration}" -print 2>/dev/null)" ]]; then
    # file too old
    rm -f "${cacheFile}" || true
  fi
}
