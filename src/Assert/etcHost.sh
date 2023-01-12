#!/usr/bin/env bash

# Check if Host is defined in etc/hosts of windows
# @param $1 hostname
# @return 1 if hostname not found
Assert::etcHost() {
  local host
  host="$1"
  assertFileExists "/etc/hosts" "root" "root" || exit 1
  if ! grep -q -E "[[:space:]]${host}([[:space:]]|$)" /etc/hosts 2>&1; then
    Log::displayError "host ${host} not configured in /etc/hosts"
    return 1
  fi
  if Assert::wsl; then
    if [[ ! -f "${BASE_MNT_C}/Windows/System32/drivers/etc/hosts" ]]; then
      Log::displayError "missing file ${BASE_MNT_C}/Windows/System32/drivers/etc/hosts"
      return 1
    fi
    if ! dos2unix <"${BASE_MNT_C}/Windows/System32/drivers/etc/hosts" | grep -q -E "[[:space:]]${host}([[:space:]]|$)"; then
      Log::displayError "Host ${host} not configured in windows host"
      return 1
    fi
  fi
  Log::displaySuccess "Host ${host} correctly configured"
}
