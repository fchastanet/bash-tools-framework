#!/usr/bin/env bash

# Check if Host is defined in etc/hosts of windows
# @param $1 hostname
# @return 1 if hostname not found
Assert::etcHost() {
  local host="$1"

  Assert::fileExists "/etc/hosts" "root" "root" || exit 1
  if ! grep -q -E "[[:space:]]${host}([[:space:]]|$)" /etc/hosts 2>&1; then
    Log::displayError "Host ${host} not configured in /etc/hosts"
    return 1
  fi
  if Assert::wsl; then
    Wsl::assertWindowsEtcHost "${host}" || return 1
  fi
  Log::displaySuccess "Host ${host} correctly configured"
}
