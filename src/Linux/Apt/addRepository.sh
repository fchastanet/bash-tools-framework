#!/usr/bin/env bash

# @description add apt repository followed by an apt-get update
# @feature Retry::default
# Linux::requireSudoCommand
# @require Linux::requireUbuntu
# @env SKIP_APT_GET_UPDATE
# @stdout diagnostics logs
Linux::Apt::addRepository() {
  if ! Linux::Apt::repositoryExists "$1"; then
    Log::displayInfo "Apt add repository $1"
    if [[ "${SKIP_APT_GET_UPDATE:-0}" = "0" ]]; then
      Retry::default sudo add-apt-repository -y --update "$1"
    else
      Retry::default sudo add-apt-repository -y "$1"
    fi
  else
    Log::displayInfo "Repository $1 is already installed"
  fi
}
