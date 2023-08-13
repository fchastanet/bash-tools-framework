#!/usr/bin/env bash

Wsl::cachedWslvar() {
  local var="$1"
  local tempEnvFile
  tempEnvFile="${TMPDIR:-/tmp}/bash_tools_wslvar_$(id -un)"

  Cache::removeCacheFileIfTooOld "${tempEnvFile}" "1"
  Cache::getPropertyValue "${tempEnvFile}" "${var}" Wsl::originalWslvar "${var}"
}
