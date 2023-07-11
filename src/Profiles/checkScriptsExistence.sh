#!/usr/bin/env bash

Profiles::checkScriptsExistence() {
  local scriptsDir="$1"
  local extension="$2"
  shift 2 || true

  for i in "$@"; do
    if [[ ! -f "${scriptsDir}/${i}${extension}" ]]; then
      Log::fatal "script ${i} doesn't exist"
    fi
  done
}
