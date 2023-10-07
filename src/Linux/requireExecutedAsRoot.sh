#!/usr/bin/env bash

# @description ensure running user is root
# @exitcode 1 if current user is not root
# @stderr diagnostics information is displayed
Linux::requireExecutedAsRoot() {
  if [[ "$(id -u)" != "0" ]]; then
    Log::fatal "this script should be executed as root"
  fi
}
