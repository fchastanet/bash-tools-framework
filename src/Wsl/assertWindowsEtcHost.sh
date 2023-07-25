#!/usr/bin/env bash

# Check if Host is defined in etc/hosts of windows
# @param $1 hostname
# @return 1 if hostname not found
Wsl::assertWindowsEtcHost() {
  local host="$1"

  Assert::fileExists "${BASE_MNT_C-/mnt/c}/Windows/System32/drivers/etc/hosts" || return 1
  if ! dos2unix <"${BASE_MNT_C-/mnt/c}/Windows/System32/drivers/etc/hosts" | grep -q -E "[[:space:]]${host}([[:space:]]|$)"; then
    Log::displayError "Host ${host} not configured in windows host"
    return 1
  fi
}
