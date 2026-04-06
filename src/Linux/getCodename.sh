#!/usr/bin/env bash

# @description retrieve linux distribution code name
# @noargs
# @exitcode 1 if /etc/os-release not found
# @exitcode 2 if VERSION_CODENAME field not found in /etc/os-release
# @stdout the linux distribution code name
Linux::getCodename() {
  if [[ ! -f /etc/os-release ]]; then
    return 1
  fi
  awk -F= '/^VERSION_CODENAME=/ { gsub(/"/, "", $2); print $2; exit }' /etc/os-release || return 2
}
