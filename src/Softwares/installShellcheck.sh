#!/usr/bin/env bash

# @description install hadolint if necessary
# @arg $1 targetFile:String
# @arg $2 maxAge:int in seconds, default to 1 month
# @feature Github::upgradeRelease
Softwares::installShellcheck() {
  local targetFile="${1:-${FRAMEWORK_VENDOR_BIN_DIR}/shellcheck}"
  local maxAge=${2:-$((30 * 24 * 3600))} # 1 month in seconds
  # shellcheck disable=SC2329
  install() {
    local file="$1"
    local targetFile="$2"
    local version="$3"
    local tempDir
    tempDir="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bash-framework-shellcheck-$$-XXXXXX)"
    (
      cd "${tempDir}" || exit 1
      tar -xJvf "${file}" >&2
      mv "shellcheck-v${version}/shellcheck" "${targetFile}"
      chmod +x "${targetFile}"
      touch -d "now" "${targetFile}"
      rm -f "${file}" || true
    )
  }
  local fileAge="-1"
  fileAge=$(File::elapsedTimeSinceLastModification "${targetFile}") || fileAge="-1"
  if ((fileAge < maxAge && fileAge >= 0)); then
    Log::displayInfo "Using cached shellcheck (age: $(Format::duration "${fileAge}"))"
    return 0
  fi
  Log::displayInfo "Shellcheck is older than 1 month, re-downloading..."
  INSTALL_CALLBACK=install Github::upgradeRelease \
    "${targetFile}" \
    "https://github.com/koalaman/shellcheck/releases/download/v@latestVersion@/shellcheck-v@latestVersion@.linux.x86_64.tar.xz"

  # ensure the timestamp is updated even if the file was already up to date to prevent repeated downloads
  touch -d "now" "${targetFile}"
}
