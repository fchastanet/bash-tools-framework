#!/usr/bin/env bash

declare -Agx bash_tools_wslvar=()
# @description retrieve wslvar using cache (cache is refreshed every day)
# @arg $1 cachedWslvar2_var:&String the variable to set by reference if the value is found
# @arg $@ args:String[] arguments to pass to wslvar
# @env WSL_TMPDIR String temp directory to store the wslvar cache (default value: PERSISTENT_TMPDIR), you can use TMPDIR instead
# @exitcode * if Linux::Wsl::originalWslvar cannot find the variable
# @stderr diagnostics information is displayed
# @require Linux::Wsl::requireWsl
# @feature cache
Linux::Wsl::cachedWslvar2() {
  # shellcheck disable=SC2034
  local -n cachedWslvar2_var="$1"
  shift || true
  local -a args=("$@")
  local tempWslvarFile="${WSL_TMPDIR:-${PERSISTENT_TMPDIR:-/tmp}}/bash_tools_wslvar"
  local key
  key="$(Linux::Wsl::getKeyFromWslpathOptions "${args[@]}")"
  Cache::getPropertyValue2 \
    "${tempWslvarFile}" \
    bash_tools_wslvar \
    cachedWslvar2_var \
    "${key}" \
    Linux::Wsl::originalWslvar "${args[@]}"
}
