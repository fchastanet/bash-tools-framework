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
Linux::Wsl::cachedWslpathFromWslVar() {
  local var="$1"
  shift || true
  local value
  value="$(Linux::Wsl::cachedWslvar "${var}" "$@")" || return 1
  Linux::Wsl::cachedWslpath "${value}" || return 1
}
