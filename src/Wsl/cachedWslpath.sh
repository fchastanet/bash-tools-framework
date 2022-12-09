#!/usr/bin/env bash

Wsl::cachedWslpath() {
  local -a args=("$@")
  local tempEnvFile, key

  tempEnvFile="${TMPDIR:-/tmp}/bash_tools_wslpath_$(id -un)"
  Wsl::removeCacheFileIfTooOld "${tempEnvFile}" "+1"

  key="$(getKeyFromWslpathOptions "$@")"
  Functions::getPropertyValue "${tempEnvFile}" "${key}" originalWslpath "${args[@]}"
}
