#!/usr/bin/env bash

# @description apt-get install
# @arg $@ softwares:String[] list of softwares to install
# @feature Retry::default
# Linux::requireSudoCommand
# @require Linux::requireUbuntu
Linux::Apt::install() {
  Retry::default sudo apt-get install -y -q "$@"
}
