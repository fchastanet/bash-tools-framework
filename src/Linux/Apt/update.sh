#!/usr/bin/env bash

# @description update apt packages list
# @feature Retry::default
# Linux::requireSudoCommand
# @require Linux::requireUbuntu
# @stdout diagnostics logs
Linux::Apt::update() {
  Log::displayInfo "Apt update ..."
  Retry::default sudo apt-get update -y --fix-missing -o Acquire::ForceIPv4=true
}
