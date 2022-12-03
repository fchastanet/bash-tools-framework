#!/usr/bin/env bash

# Public: exits with message if current user is root
#
# **Exit**: code 1 if current user is root
Assert::expectNonRootUser() {
  currentUserId=$(id -u)
  if [[ "${currentUserId}" = "0" ]]; then
    Log::fatal "The script must not be run as root"
  fi
}
