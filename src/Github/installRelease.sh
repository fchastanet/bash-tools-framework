#!/usr/bin/env bash

# install binary with the exact version provided using retry
# @param {String}   targetFile target binary file (eg: /usr/local/bin/kind)
# @param {String}   releaseUrl github release url (eg: https://github.com/kubernetes-sigs/kind/releases/download/@latestVersion@/kind-linux-amd64)
#    the placeholder @latestVersion@ will be replaced by the provided version
# @param {String}   argVersion the argument used to get the version of the command (default: --version)
# @param {Function} versionCallback function called to get software version (default: Version::getCommandVersionFromPlainText will call software with argument --version)
# @param {Function} installCallback function called to install the file retrieved on github (default copy as is and set execution bit)
# @output log messages about retry, install, upgrade
Github::installRelease() {
  local targetFile="$1"
  local releaseUrl="$2"
  local exactVersion="$3"
  local argVersion="${4:---version}"
  local versionCallback="${5:-Version::getCommandVersionFromPlainText}"
  # shellcheck disable=SC2034
  local installCallback="${6:-}"

  local currentVersion="not existing"
  if [[ -f "${targetFile}" ]]; then
    currentVersion="$(${versionCallback} "${targetFile}" "${argVersion}" 2>&1 || true)"
  fi
  if [[ "${currentVersion}" != "${exactVersion}" ]]; then
    Log::displayInfo "Installing ${targetFile} from version ${currentVersion} to ${exactVersion}"
    url="$(echo "${releaseUrl}" | sed -E "s/@latestVersion@/${exactVersion}/g")"
    Log::displayInfo "Using url ${url}"
    newSoftware=$(mktemp -p "${TMPDIR:-/tmp}" -t github.newSoftware.XXXX)
    Retry::default curl \
      -L \
      -o "${newSoftware}" \
      --fail \
      "${url}"

    Github::defaultInstall "${newSoftware}" "${targetFile}" "${exactVersion}" "${installCallback}"
  fi
}
