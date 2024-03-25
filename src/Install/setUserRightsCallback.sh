#!/usr/bin/env bash

# @description install callback
#   set file with root ownership and execution bit
# @arg $1 fromFile:String
# @arg $2 targetFile:String
# @arg $3 userName:String (optional) (default: ${USERNAME}) the user name that will be used to set target files ownership
# @arg $4 userGroup:String (optional) (default: ${USERNAME}) the group name that will be used to set target files ownership
# @env USERNAME (default: root) the user name that will be used to set target files ownership
# @env USERGROUP (default: root) the group name that will be used to set target files ownership
# @env SUDO String allows to use custom sudo prefix command
# @exitcode 1 on any failure
# @see Install::file
Install::setUserRightsCallback() {
  # shellcheck disable=SC2034 # $1 not used
  local fromFile="$1"
  local targetFile="$2"
  local userName="${3:-${USERNAME:-root}}"
  local userGroup="${4:-${USERGROUP:-root}}"

  ${SUDO:-} chown "${userName}":"${userGroup}" "${targetFile}"
}
