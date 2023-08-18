#!/usr/bin/env bash

# @description install callback
#   set file with root ownership and execution bit
# @arg $1 fromFile:String
# @arg $2 targetFile:String
# @exitcode 1 on any failure
# @see Install::file
Install::setRootExecutableCallback() {
  # shellcheck disable=SC2034
  local fromFile="$1"
  local targetFile="$2"
  chown root:root "${targetFile}"
  chmod +x "${targetFile}"
}
