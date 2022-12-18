#!/usr/bin/env bash

Wsl::cachedWslpath() {
  local -a args=("$@")
  local tempEnvFile key

  tempEnvFile="${TMPDIR:-/tmp}/bash_tools_wslpath_$(id -un)"
  Cache::removeCacheFileIfTooOld "${tempEnvFile}" "+1"

  key="$(Wsl::getKeyFromWslpathOptions "$@")"
  Cache::getPropertyValue "${tempEnvFile}" "${key}" originalWslpath "${args[@]}"
}
