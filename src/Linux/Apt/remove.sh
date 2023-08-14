#!/usr/bin/env bash

# @description remove ubuntu packages
# @arg $@ softwares:String[] list of softwares to remove
# @feature Retry::default
# @feature sudo
# @require Linux::requireUbuntu
Linux::Apt::remove() {
  Retry::default sudo dpkg --purge "$@"
}
