#!/usr/bin/env bash

# @description install hadolint if necessary
# @arg $1 targetFile:String
# @feature Github::upgradeRelease
Softwares::installShellcheck() {
  local targetFile="${1:-${FRAMEWORK_VENDOR_BIN_DIR}/shellcheck}"
  # shellcheck disable=SC2317
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
      rm -f "${file}" || true
    )
  }
  INSTALL_CALLBACK=install Github::upgradeRelease \
    "${targetFile}" \
    "https://github.com/koalaman/shellcheck/releases/download/v@latestVersion@/shellcheck-v@latestVersion@.linux.x86_64.tar.xz"
}
