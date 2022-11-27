#!/usr/bin/env bash

# try to ping the given hostname
# @param $1 hostname
# @return 1 if hostname not pinged
Dns::pingHost() {
  local hostName="$1"
  if ! ping -c 1 "${hostName}" >/dev/null 2>&1; then
    Log::displayError "unable to ping ${hostName}"
    return 1
  else
    Log::displaySuccess "${hostName} accessible"
  fi
}
