#!/usr/bin/env bash

# @description retrieve wslvar using cache (cache is refreshed every day)
# @arg $@ args:String[] arguments to pass to wslvar
# @env WSL_TMPDIR String temp directory to store the wslvar cache (default value: TMPDIR), you can use PERSISTENT_TMPDIR instead
# @exitcode * if Linux::Wsl::originalWslvar cannot find the variable
# @stderr diagnostics information is displayed
# @require Linux::Wsl::requireWsl
# @feature cache
Linux::Wsl::cachedWslvar() {
  local tempEnvFile
  tempEnvFile="${WSL_TMPDIR:-${PERSISTENT_TMPDIR:-/tmp}}/bash_tools_wslvar_$(id -un)"

  Cache::getPropertyValue "${tempEnvFile}" "$1" Linux::Wsl::originalWslvar "$@"
}
