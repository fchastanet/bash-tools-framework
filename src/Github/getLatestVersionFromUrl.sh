#!/usr/bin/env bash

# @description Retrieve the latest version number for given github url
# @arg $1 releaseUrl:String github url from which repository will be extracted
# @stderr log messages about retry
# @stdout the version number retrieved
Github::getLatestVersionFromUrl() {
  local releaseUrl="$1"
  local repo
  local latestVersion
  # extract repo from github url
  repo="$(Github::extractRepoFromGithubUrl "${releaseUrl}")" || return 1

  # get latest release version
  if ! Github::getLatestRelease "${repo}" latestVersion; then
    Log::displayError "Repository ${repo} latest version not found"
    return 1
  fi
  Log::displayInfo "Repo ${repo} latest version found is ${latestVersion}"
  echo "${latestVersion}"
}
