#!/usr/bin/env bash

# @description checks if Systemd is running
# @noargs
# @exitcode 1 if systemd is not running
# @stdout diagnostics information
Linux::isSystemdRunning() {
  if [[ "$(readlink -f /sbin/init)" = "/usr/lib/systemd/systemd" ]] && systemctl status --no-pager &>/dev/null; then
    Log::displayInfo "SystemD is running"
    return 0
  fi
  Log::displayInfo "SystemD is not running"
  return 1
}
