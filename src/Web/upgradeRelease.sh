#!/usr/bin/env bash

# @description upgrade given binary to latest release using retry
#
# releasesUrl argument : the placeholder @latestVersion@ will be replaced by the latest release version
# @arg $1 targetFile:String target binary file (eg: /usr/local/bin/kind)
# @arg $2 releasesUrl:String url on which we can query all available versions (eg: "https://go.dev/dl/?mode=json")
# @arg $3 downloadReleaseUrl:String url from which the software will be downloaded (eg: https://storage.googleapis.com/golang/go@latestVersion@.linux-amd64.tar.gz)
# @arg $4 softVersionArg:String parameter to add to existing command to compute current version
# @arg $5 exactVersion:String if you want to retrieve a specific version instead of the latest
# @stdout log messages about retry, install, upgrade
# @env FILTER_LAST_VERSION_CALLBACK a callback to filter the latest version from releasesUrl
# @env SOFT_VERSION_CALLBACK a callback to execute command version
# @env PARSE_VERSION_CALLBACK a callback to parse the version of the existing command
# @env INSTALL_CALLBACK a callback to install the software downloaded
# @env CURL_CONNECT_TIMEOUT number of seconds before giving up host connection
# @env VERSION_PLACEHOLDER a placeholder to replace in downloadReleaseUrl (default: @latestVersion@)
Web::upgradeRelease() {
  local targetFile="$1"
  local releasesUrl="$2"
  local downloadReleaseUrl="$3"
  local softVersionArg="${4:---version}"
  local exactVersion="${5:-}"
  # options from env variables
  local filterLastVersionCallback="${FILTER_LAST_VERSION_CALLBACK:-Version::parse}"
  local softVersionCallback="${SOFT_VERSION_CALLBACK:-Version::getCommandVersionFromPlainText}"
  local installCallback="${INSTALL_CALLBACK:-}"

  local currentVersion="not existing"
  if [[ -f "${targetFile}" ]]; then
    currentVersion="$(${softVersionCallback} "${targetFile}" "${softVersionArg}" || true)"
  fi
  if [[ -z "${exactVersion}" ]]; then
    local latestVersion
    latestVersion="$(Web::getReleases "${releasesUrl}" | ${filterLastVersionCallback})" || {
      Log::displayError "latest version not found on ${releasesUrl}"
      return 1
    }
    Log::displayInfo "Latest version found is ${latestVersion}"

    exactVersion="${latestVersion}"
  fi
  local url="${downloadReleaseUrl//${VERSION_PLACEHOLDER:-@latestVersion@}/${exactVersion}}"
  if [[ -n "${exactVersion}" ]] && ! Github::isReleaseVersionExist "${url}"; then
    Log::displayError "${targetFile} version ${exactVersion} doesn't exist on github"
    return 2
  fi
  Log::displayDebug "currentVersion: '${currentVersion}'"
  Log::displayDebug "exactVersion: '${exactVersion}'"
  if [[ "${currentVersion}" = "${exactVersion}" ]]; then
    Log::displayInfo "${targetFile} version ${exactVersion} already installed"
  else
    if [[ -z "${currentVersion}" ]]; then
      Log::displayInfo "Installing ${targetFile} with version ${exactVersion}"
    else
      Log::displayInfo "Upgrading ${targetFile} from version ${currentVersion} to ${exactVersion}"
    fi
    Log::displayInfo "Using url ${url}"
    newSoftware=$(mktemp -p "${TMPDIR:-/tmp}" -t web.newSoftware.XXXX)
    Retry::default curl \
      -L \
      --connect-timeout "${CURL_CONNECT_TIMEOUT:-5}" \
      -o "${newSoftware}" \
      --fail \
      "${url}"

    CURRENT_VERSION="${currentVersion}" Github::defaultInstall "${newSoftware}" "${targetFile}" "${exactVersion}" "${installCallback}"
  fi
}
