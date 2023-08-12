#!/usr/bin/env bash

# @description exits with message if current user is root
#
# **Exit**: code 1 if current user is root
Assert::expectNonRootUser() {
  if [[ "$(id -u)" = "0" ]]; then
    Log::fatal "The script must not be run as root"
  fi
}
