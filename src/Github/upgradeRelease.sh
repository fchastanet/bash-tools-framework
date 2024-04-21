#!/usr/bin/env bash

# @description upgrade given binary to latest github release using retry
#
# downloadReleaseUrl argument : the placeholder @latestVersion@ will be replaced by the latest release version
# @arg $1 targetFile:String target binary file (eg: /usr/local/bin/kind)
# @arg $2 downloadReleaseUrl:String github release url (eg: https://github.com/kubernetes-sigs/kind/releases/download/@latestVersion@/kind-linux-amd64)
# @arg $3 softVersionArg:String parameter to add to existing command to compute current version
# @arg $4 softVersionCallback:Function function called to get software version (default: Version::getCommandVersionFromPlainText will call software with argument --version)
# @arg $5 installCallback:Function function called to install the file retrieved on github (default copy as is and set execution bit)
# @arg $6 softVersionCallback:Function function to call to filter the version retrieved from github (Default: Version::parse)
# @stdout log messages about retry, install, upgrade
# @env SOFT_VERSION_CALLBACK pass softVersionCallback by env variable instead of passing it by arg
# @env INSTALL_CALLBACK pass installCallback by env variable instead of passing it by arg
# @env CURL_CONNECT_TIMEOUT number of seconds before giving up host connection
Github::upgradeRelease() {
  local targetFile="$1"
  local downloadReleaseUrl="$2"
  local softVersionArg="${3:---version}"
  local softVersionCallback="${4:-${SOFT_VERSION_CALLBACK:-Version::getCommandVersionFromPlainText}}"
  # shellcheck disable=SC2034
  local installCallback="${5:-${INSTALL_CALLBACK:-}}"
  local parseGithubVersionCallback="${6:-${PARSE_VERSION_CALLBACK:-Version::parse}}"

  local repo
  repo="$(Github::extractRepoFromGithubUrl "${downloadReleaseUrl}")"
  local releasesUrl="https://api.github.com/repos/${repo}/releases/latest"

  # shellcheck disable=SC2317
  extractVersion() {
    Version::githubApiExtractVersion | "${parseGithubVersionCallback}"
  }
  FILTER_LAST_VERSION_CALLBACK=${FILTER_LAST_VERSION_CALLBACK:-extractVersion} \
  SOFT_VERSION_CALLBACK="${softVersionCallback}" \
    Web::upgradeRelease \
      "${targetFile}" \
      "${releasesUrl}" \
      "${downloadReleaseUrl}" \
      "${softVersionArg}"
}
