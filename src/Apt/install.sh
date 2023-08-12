#!/usr/bin/env bash

# @src src/Apt/install.sh
# @description apt-get install
# @arg $@ softwares:String[] list of softwares to install
# @feature Retry::default
# @feature sudo
# @constraint Apt::requiresUbuntu
Apt::install() {
  Retry::default sudo apt-get install -y -q "$@"
}
