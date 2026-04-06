#!/usr/bin/env bash

# @description retrieve linux distributor id
# @noargs
# @exitcode 1 if /etc/os-release not found
# @exitcode 2 if ID field not found in /etc/os-release
# @stdout the linux distributor id
Linux::getDistributorId() {
  if [[ ! -f /etc/os-release ]]; then
    return 1
  fi
  awk -F= '/^ID=/ { gsub(/"/, "", $2); print $2; exit }' /etc/os-release || return 2
}
