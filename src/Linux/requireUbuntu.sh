#!/usr/bin/env bash

# @description ensure linux distribution is ubuntu
# @exitcode 1 if linux distribution is not ubuntu
Linux::requireUbuntu() {
  if ! Array::contains "$(Linux::getDistributorId)" "ubuntu" "debian"; then
    Log::fatal "this script should be executed under Ubuntu or Debian OS"
  fi
}
