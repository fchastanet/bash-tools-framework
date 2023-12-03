#!/usr/bin/env bash

# @description Check that command version is greater than expected minimal version
# display warning if command version greater than expected minimal version
# display error if command version less than expected minimal version and exit 1
# @arg $1 commandName:String command path
# @arg $2 argVersion:String command line parameters to launch to get command version
# @arg $3 minimalVersion:String expected minimal command version
# @arg $4 parseVersionCallback:Function
# @arg $5 help:String optional help message to display if command does not exist
# @exitcode 0 if command version greater or equal to expected minimal version
# @exitcode 1 if command version less than expected minimal version
# @exitcode 2 if command does not exist
Version::checkMinimal() {
  local commandName="$1"
  local argVersion="$2"
  local minimalVersion="$3"
  local parseVersionCallback=${4:-Version::parse}
  local help="${5:-}"

  Assert::commandExists "${commandName}" "${help}" || return 2

  local version
  version="$("${commandName}" "${argVersion}" 2>&1 | ${parseVersionCallback})"

  Log::displayDebug "check ${commandName} version ${version} against minimal ${minimalVersion}"

  Version::compare "${version}" "${minimalVersion}" || {
    local result=$?
    if [[ "${result}" = "1" ]]; then
      Log::displayDebug "${commandName} version is ${version} greater than ${minimalVersion}, OK let's continue"
    elif [[ "${result}" = "2" ]]; then
      Log::displayError "${commandName} minimal version is ${minimalVersion}, your version is ${version}"
      return 1
    fi
    return 0
  }

}
