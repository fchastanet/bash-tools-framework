#!/usr/bin/env bash

# @description remove ubuntu packages
# @arg $@ softwares:String[] list of softwares to remove
# @feature Retry::default
# @feature sudo
# @constraint Apt::requiresUbuntu
Apt::remove() {
  Retry::default sudo dpkg --purge "$@"
}
