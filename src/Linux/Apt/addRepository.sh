#!/usr/bin/env bash

# @description add apt repository followed by an apt-get update
# @feature Retry::default
# Linux::requireSudoCommand
# @require Linux::requireUbuntu
# @stdout diagnostics logs
Linux::Apt::addRepository() {
  Log::displayInfo "Apt add repository $1"
  Retry::default sudo add-apt-repository -y "$1"
  Retry::default Linux::Apt::update
}
