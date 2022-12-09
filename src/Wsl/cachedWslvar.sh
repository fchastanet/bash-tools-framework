#!/usr/bin/env bash

Wsl::cachedWslvar() {
  local var="$1"
  local tempEnvFile
  tempEnvFile="${TMPDIR:-/tmp}/bash_tools_wslvar_$(id -un)"

  Wsl::removeCacheFileIfTooOld "${tempEnvFile}" "+1"
  Functions::getPropertyValue "${tempEnvFile}" "${var}" wsl::originalWslvar "${var}"
}
