#!/usr/bin/env bash

# @description execute command passed as arguments
# using sudo with environment inherited if current user is not already the targeted user
# @arg $@ args:String[] the command to execute as sudo
# @env USERNAME String sudo as this user (root by default)
# @exitcode 1 exit code of sudo command
# @require Linux::requireSudoCommand
# Linux::requireSudoCommand
Linux::Sudo::asUserInheritEnv() {
  if [[ "$(id -un)" = "${USERNAME:-root}" ]]; then
    "$@"
  else
    sudo -i -u "${USERNAME:-root}" "$@"
  fi
}
