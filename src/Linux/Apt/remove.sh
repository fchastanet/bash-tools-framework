#!/usr/bin/env bash

# @description remove ubuntu packages
# @arg $@ softwares:String[] list of softwares to remove
# @feature Retry::default
# Linux::requireSudoCommand
# @require Linux::requireUbuntu
# @stdout diagnostics logs
Linux::Apt::remove() {
  Log::displayInfo "Apt remove $*"
  Retry::default sudo dpkg --purge "$@"
}
