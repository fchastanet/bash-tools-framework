#!/usr/bin/env bash

# @description check if host can accessed using ssh private key
# without requiring interactivity
# @arg $1 host:String the host to join
# @arg $@ args:String[] other parameters to pass to the ssh command
# @exitcode 1 if ssh fails
# @exitcode 2 if missing host argument
# @require Ssh::requireSshCommand
Ssh::checkAccess() {
  local host="$1"
  shift 1 || true
  if [[ -z "${host}" ]]; then
    Log::displayError "You must provide a host as first argument"
    exit 2
  fi
  Log::displayInfo "Checking ${host} can be accessed non interactively using ssh"
  ssh \
    -q \
    -o PubkeyAuthentication=yes \
    -o PasswordAuthentication=no \
    -o KbdInteractiveAuthentication=no \
    -o ChallengeResponseAuthentication=no \
    "${host}" "$@" exit
}
