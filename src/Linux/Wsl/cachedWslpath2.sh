#!/usr/bin/env bash

declare -Agx bash_tools_wslpath=()
# @description retrieve wslpath using cache (cache is refreshed every day)
# @arg $@ args:String[] arguments to pass to wslpath
# @env WSL_TMPDIR String temp directory to store the wslpath cache (default value: TMPDIR), you can use PERSISTENT_TMPDIR instead
# @exitcode * if Linux::Wsl::originalWslpath cannot find the path
# @stderr diagnostics information is displayed
# @require Linux::Wsl::requireWsl
# @feature cache
Linux::Wsl::cachedWslpath2() {
  # shellcheck disable=SC2034
  local -n cachedWslpath2_value=$1
  shift || true
  local tempEnvFile key
  tempEnvFile="${WSL_TMPDIR:-${PERSISTENT_TMPDIR:-/tmp}}/bash_tools_wslpath"

  key="$(Linux::Wsl::getKeyFromWslpathOptions "$@")"
  Cache::getPropertyValue2 \
    "${tempEnvFile}" \
    bash_tools_wslpath \
    cachedWslpath2_value \
    "${key}" \
    Linux::Wsl::originalWslpath "$@"
}
