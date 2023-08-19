#!/usr/bin/env bash

# @description update apt packages list
# @feature Retry::default
# Linux::requireSudoCommand
# @require Linux::requireUbuntu
Linux::Apt::update() {
  Retry::default sudo apt-get update -y --fix-missing -o Acquire::ForceIPv4=true
}
