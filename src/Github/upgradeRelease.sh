#!/usr/bin/env bash

# upgrade given binary to latest github release using retry
# @param {String}   github repository eg: kubernetes-sigs/kind
# @param {String}   targetFile target binary file (eg: /usr/local/bin/kind)
# @param {String}   releaseUrl github release url (eg: https://github.com/kubernetes-sigs/kind/releases/download/@latestVersion@/kind-linux-amd64)
#    the placeholder @latestVersion@ will be replaced by the latest release version
# @param {Function} versionCallback function called to get software version (default: Version::ask will call software with argument --version)
# @param {Function} installCallback function called to install the file retrieved on github (default copy as is and set execution bit)
# @output log messages about retry, install, upgrade
Github::upgradeRelease() {
  local repo="$1"
  local targetFile="$2"
  local releaseUrl="$3"
  local versionCallback=${4:-Version::ask}
  local installCallback=${5:-}
  local latestVersion

  Github::getLatestRelease "${repo}" latestVersion

  local currentVersion="not existing"
  if [[ -f "${targetFile}" ]]; then
    currentVersion="$(${versionCallback} "${targetFile}" 2>&1 | grep -oP '[0-9]+\.[0-9]+(\.[0-9]+)' || true)"
  fi
  if [[ "${currentVersion}" = "${latestVersion}" ]]; then
    Log::displayInfo "${targetFile} version ${latestVersion} already installed"
  else
    if [[ -z "${currentVersion}" ]]; then
      Log::displayInfo "Installing ${targetFile} with version ${latestVersion}"
    else
      Log::displayInfo "Upgrading ${targetFile} from version ${currentVersion} to ${latestVersion}"
    fi
    local url
    url="$(echo "${releaseUrl}" | sed -E "s/@latestVersion@/${latestVersion}/g")"
    Log::displayInfo "Using url ${url}"
    Retry::default curl \
      -L \
      -o /tmp/newSoftware \
      --fail \
      "${url}"

    # shellcheck disable=SC2086
    if [[ "$(type -t ${installCallback})" = "function" ]]; then
      ${installCallback} "/tmp/newSoftware" "${targetFile}"
    else
      mkdir -p "$(dirname "${targetFile}")"
      mv /tmp/newSoftware "${targetFile}"
      chmod +x "${targetFile}"
      hash -r
    fi
    rm -f /tmp/newSoftware || true
  fi
}
