#!/usr/bin/env bash

Profiles::checkScriptsExistence() {
  local scriptsDir="$1"
  shift || true

  for i in "$@"; do
    if [[ ! -f "${scriptsDir}/${i}.sh" ]]; then
      Log::fatal "script ${i} doesn't exist"
    fi
  done
}
