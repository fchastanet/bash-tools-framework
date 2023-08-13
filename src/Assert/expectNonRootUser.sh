#!/usr/bin/env bash

# @description exits with message if current user is root
# @noargs
# @exitcode 1 if current user is root
# @stderr diagnostics information is displayed
Assert::expectNonRootUser() {
  if [[ "$(id -u)" = "0" ]]; then
    Log::fatal "The script must not be run as root"
  fi
}
