#!/usr/bin/env bash

# @description retrieve path from wslvar and then use wslpath to resolve it
# using cache (cache is refreshed every day)
# @arg $1 var:String the var to retrieve using wslvar
# @arg $@ args:String[] (optional) additional arguments to pass to wslvar
# @env WSL_TMPDIR String temp directory to store the wslpath cache (default value: TMPDIR), you can use PERSISTENT_TMPDIR instead
# @exitcode * if Linux::Wsl::originalWslpath cannot find the path or Linux::Wsl::originalWslvar cannot find the var
# @stderr diagnostics information is displayed
# @require Linux::Wsl::requireWsl
# @feature cache
Linux::Wsl::cachedWslpathFromWslVar2() {
  # shellcheck disable=SC2034
  local -n cachedWslpathFromWslVar2_value=$1
  shift || true
  local value
  Linux::Wsl::cachedWslvar2 value "$@"
  Linux::Wsl::cachedWslpath2 cachedWslpathFromWslVar2_value "${value}" || return 1
}
