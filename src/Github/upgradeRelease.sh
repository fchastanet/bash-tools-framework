#!/usr/bin/env bash

# @description upgrade given binary to latest github release using retry
#
# releaseUrl argument : the placeholder @latestVersion@ will be replaced by the latest release version
# @arg $1 targetFile:String target binary file (eg: /usr/local/bin/kind)
# @arg $2 releaseUrl:String github release url (eg: https://github.com/kubernetes-sigs/kind/releases/download/@latestVersion@/kind-linux-amd64)
# @arg $3 softVersionArg:String parameter to add to existing command to compute current version
# @arg $4 softVersionCallback:Function function called to get software version (default: Version::getCommandVersionFromPlainText will call software with argument --version)
# @arg $5 installCallback:Function function called to install the file retrieved on github (default copy as is and set execution bit)
# @arg $6 parseGithubVersionCallback:Function function to call to filter the version retrieved from github (Default: Version::parse)
# @stdout log messages about retry, install, upgrade
# @env SOFT_VERSION_CALLBACK pass softVersionCallback by env variable instead of passing it by arg
# @env PARSE_VERSION_CALLBACK pass parseGithubVersionCallback by env variable instead of passing it by arg
# @env INSTALL_CALLBACK pass installCallback by env variable instead of passing it by arg
Github::upgradeRelease() {
  local targetFile="$1"
  local releaseUrl="$2"
  local softVersionArg="${3:---version}"
  local softVersionCallback="${4:-${SOFT_VERSION_CALLBACK:-Version::getCommandVersionFromPlainText}}"
  # shellcheck disable=SC2034
  local installCallback="${5:-${INSTALL_CALLBACK:-}}"
  local parseGithubVersionCallback="${6:-${PARSE_VERSION_CALLBACK:-Version::parse}}"
  local latestVersion
  local repo

  repo="$(Github::extractRepoFromGithubUrl "${releaseUrl}")"
  Github::getLatestRelease "${repo}" latestVersion ||
    Log::fatal "Repo ${repo} latest version not found"
  if [[ "$(type -t "${parseGithubVersionCallback}")" = "function" ]]; then
    latestVersion="$(${parseGithubVersionCallback} <<<"${latestVersion}")"
  fi
  Log::displayInfo "Repo ${repo} latest version found is ${latestVersion}"

  local currentVersion="not existing"
  if [[ -f "${targetFile}" ]]; then
    currentVersion="$(${softVersionCallback} "${targetFile}" "${softVersionArg}" 2>&1 || true)"
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
    newSoftware=$(mktemp -p "${TMPDIR:-/tmp}" -t github.newSoftware.XXXX)
    Retry::default curl \
      -L \
      -o "${newSoftware}" \
      --fail \
      "${url}"

    Github::defaultInstall "${newSoftware}" "${targetFile}" "${latestVersion}" "${installCallback}"
  fi
}
