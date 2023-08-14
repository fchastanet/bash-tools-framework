#!/usr/bin/env bash

# @description Check if Host is defined in etc/hosts of linux and windows (if applicable)
# @arg $1 host:String
# @exitcode 1 if /etc/hosts doesn't exist in linux
# @exitcode 2 if host doesn't exist in linux /etc/hosts
# @exitcode 3 if host doesn't exist in windows etc/hosts or windows etc/hosts doesn't exists
# @stderr diagnostics information is displayed
# @see Linux::Wsl::assertWindowsEtcHost
Assert::etcHost() {
  local host="$1"

  Assert::fileExists "/etc/hosts" "root" "root" || return 1
  if ! grep -q -E "[[:space:]]${host}([[:space:]]|$)" /etc/hosts 2>&1; then
    Log::displayError "Host ${host} not configured in /etc/hosts"
    return 2
  fi
  if Assert::wsl; then
    Linux::Wsl::assertWindowsEtcHost "${host}" || return 3
  fi
  Log::displaySuccess "Host ${host} correctly configured"
}
