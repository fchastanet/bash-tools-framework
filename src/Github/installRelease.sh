#!/usr/bin/env bash

# @description install binary with the exact version provided using retry
#
# releaseUrl argument: the placeholder @latestVersion@ will be replaced by the provided version
# @arg $1 targetFile:String    target binary file (eg: /usr/local/bin/kind)
# @arg $2 releaseUrl:String    github release url (eg: https://github.com/kubernetes-sigs/kind/releases/download/@latestVersion@/kind-linux-amd64)
# @arg $3 exactVersion:String  which exact version to get
# @arg $4 argVersion:String    the argument used to get the version of the command (default: --version)
# @arg $5 versionCallback:Function called to get software version (default: Version::getCommandVersionFromPlainText will call software with argument --version)
# @arg $6 installCallback:Function called to install the file retrieved on github (default copy as is and set execution bit)
# @stdout log messages about retry, install, upgrade
# @env CURL_CONNECT_TIMEOUT number of seconds before giving up host connection
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
      --connect-timeout "${CURL_CONNECT_TIMEOUT:-5}" \
      -o "${newSoftware}" \
      --fail \
      "${url}"

    Github::defaultInstall "${newSoftware}" "${targetFile}" "${exactVersion}" "${installCallback}"
  fi
}
