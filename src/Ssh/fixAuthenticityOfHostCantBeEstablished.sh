#!/usr/bin/env bash

# @description Fix ssh issues
# - The authenticity of host 'www.host.net (140.82.121.4)' can't be established
# - And Offending key for IP
# @arg $1 host:String the host to fix
# @env HOME String
# @exitcode 1 is ssh-keygen fails
# @require Ssh::requireSshKeygenCommand
# @require Ssh::requireSshKeyscanCommand
Ssh::fixAuthenticityOfHostCantBeEstablished() {
  local host="$1"
  Log::displayInfo "Adding ${host} to the list of known ssh hosts"
  if [[ ! -d "${HOME}/.ssh" ]]; then
    mkdir -p "${HOME}/.ssh" || return 1
  fi
  touch "${HOME}/.ssh/known_hosts" || return 1
  ssh-keygen -R "${host}" || return 1 # remove host before adding it to prevent duplication
  ssh-keyscan "${host}" >>"${HOME}/.ssh/known_hosts" || true
}
