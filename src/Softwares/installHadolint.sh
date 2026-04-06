#!/usr/bin/env bash

# @description install hadolint if necessary
# @arg $1 targetFile:String
# @feature Github::upgradeRelease
Softwares::installHadolint() {
  local targetFile="${1:-${FRAMEWORK_VENDOR_BIN_DIR}/hadolint}"
  local maxAge=${2:-$((30 * 24 * 3600))} # 1 month in seconds
  local fileAge="-1"
  fileAge=$(File::elapsedTimeSinceLastModification "${targetFile}") || fileAge="-1"
  if ((fileAge < maxAge && fileAge >= 0)); then
    Log::displayInfo "Using cached hadolint (age: $(Format::duration "${fileAge}"))"
    return 0
  fi
  Log::displayInfo "Hadolint is older than 1 month, re-downloading..."
  Github::upgradeRelease \
    "${targetFile}" \
    "https://github.com/hadolint/hadolint/releases/download/v@latestVersion@/hadolint-Linux-x86_64"
}
