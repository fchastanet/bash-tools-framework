#!/usr/bin/env bash

# Check that command version is greater than expected minimal version
# display warning if command version greater than expected minimal version
# display error if command version less than expected minimal version and exit 1
# @param {String} $1 command path
# @param {String} $2 command line parameters to launch to get command version
# @param {String} $3 expected minimal command version
# @param {String} $4 optional help message to display if command does not exist
# @return 1 if command version less than expected minimal version, 0 otherwise
# @return 2 if command does not exist
Version::checkMinimal() {
  local commandName="$1"
  local argVersion="$2"
  local minimalVersion="$3"
  local parseVersionCallback=${4:-Version::parse}
  local help="${4:-}"

  Assert::commandExists "${commandName}" "${help}" || return 2

  local version
  version="$("${commandName}" "${argVersion}" 2>&1 | ${parseVersionCallback})"

  Log::displayDebug "check ${commandName} version ${version} against minimal ${minimalVersion}"

  Version::compare "${version}" "${minimalVersion}" || {
    local result=$?
    if [[ "${result}" = "1" ]]; then
      Log::displayWarning "${commandName} version is ${version} greater than ${minimalVersion}, OK let's continue"
    elif [[ "${result}" = "2" ]]; then
      Log::displayError "${commandName} minimal version is ${minimalVersion}, your version is ${version}"
      return 1
    fi
    return 0
  }

}
