#!/usr/bin/env bash

# @description ensure running user is not root
# @exitcode 1 if current user is root
# @stderr diagnostics information is displayed
Linux::requireExecutedAsUser() {
  if [[ "$(id -u)" = "0" ]]; then
    Log::fatal "this script should be executed as normal user"
  fi
}
