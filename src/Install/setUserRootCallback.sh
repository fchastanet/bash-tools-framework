#!/usr/bin/env bash

# @description install callback
#   set file with root ownership
# @arg $1 fromFile:String
# @arg $2 targetFile:String
# @exitcode 1 on any failure
# @env SUDO String allows to use custom sudo prefix command
# @see Install::file
Install::setUserRootCallback() {
  # shellcheck disable=SC2034 # $1 not used
  local fromFile="$1"
  local targetFile="$2"
  ${SUDO:-} chown root:root "${targetFile}"
}
