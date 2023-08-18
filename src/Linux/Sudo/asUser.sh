#!/usr/bin/env bash

# @description execute command passed as arguments
# using sudo if current user is not already the targeted user
#
# @arg $@ args:String[] the command to execute as sudo
# @env USERNAME String sudo as this user (root by default)
# @exitcode 1 exit code of command
# @require Linux::requireSudoCommand
# @feature sudo
Linux::Sudo::asUser() {
  if [[ "$(id -un)" = "${USERNAME:-root}" ]]; then
    "$@"
  else
    sudo -u "${USERNAME:-root}" "$@"
  fi
}
