#!/usr/bin/env bash

# @description install hadolint if necessary
# @arg $1 targetFile:String
# @feature Github::upgradeRelease
Softwares::installHadolint() {
  local targetFile="${1:-${FRAMEWORK_VENDOR_BIN_DIR}/hadolint}"
  Github::upgradeRelease \
    "${targetFile}" \
    "https://github.com/hadolint/hadolint/releases/download/v@latestVersion@/hadolint-Linux-x86_64"
}
