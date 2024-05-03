#!/usr/bin/env bash

# @description retrieve path from wslvar and then use wslpath to resolve it
# using cache (cache is refreshed every day)
# @arg $1 var:String the var to retrieve using wslvar
# @arg $@ args:String[] (optional) additional arguments to pass to wslvar
# @env WSL_TMPDIR String temp directory to store the wslpath cache (default value: PERSISTENT_TMPDIR), you can use TMPDIR instead
# @exitcode 1 if var cannot be found in cache nor using Linux::Wsl::originalWslvar
# @exitcode 2 if path cannot be found in cache nor using Linux::Wsl::originalWslpath
# @stderr diagnostics information is displayed
# @require Linux::Wsl::requireWsl
# @feature cache
Linux::Wsl::cachedWslpathFromWslVar2() {
  # shellcheck disable=SC2034
  local -n cachedWslpathFromWslVar2_value=$1
  shift || true
  local value
  Linux::Wsl::cachedWslvar2 value "$@" || return 1
  Linux::Wsl::cachedWslpath2 cachedWslpathFromWslVar2_value "${value}" || return 2
}
