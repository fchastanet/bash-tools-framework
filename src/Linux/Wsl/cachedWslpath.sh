#!/usr/bin/env bash

# @description retrieve wslpath using cache (cache is refreshed every day)
# @arg $@ args:String[] arguments to pass to wslpath
# @env WSL_TMPDIR String temp directory to store the wslpath cache (default value: TMPDIR), you can use PERSISTENT_TMPDIR instead
# @exitcode * if Linux::Wsl::originalWslpath cannot find the path
# @stderr diagnostics information is displayed
# @require Linux::Wsl::requireWsl
# @feature cache
Linux::Wsl::cachedWslpath() {
  local -a args=("$@")
  local tempEnvFile key
  tempEnvFile="${WSL_TMPDIR:-${PERSISTENT_TMPDIR:-/tmp}}/bash_tools_wslpath_$(id -un)"

  key="$(Linux::Wsl::getKeyFromWslpathOptions "$@")"
  Cache::getPropertyValue "${tempEnvFile}" "${key}" Linux::Wsl::originalWslpath "${args[@]}"
}
