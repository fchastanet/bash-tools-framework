#!/usr/bin/env bash

# @description try to ping the given hostname
# @arg $1 host:String hostname
# @exitcode 1 if hostname not pinged
# @stderr diagnostics information is displayed
Dns::pingHost() {
  local hostName="$1"
  if ! ping -c 1 "${hostName}" >/dev/null 2>&1; then
    Log::displayError "unable to ping ${hostName}"
    return 1
  else
    Log::displaySuccess "${hostName} accessible"
  fi
}
