#!/usr/bin/env bash

# @description check if apt package is installed
# @arg $1 package:String the package name to check
# @require Linux::requireUbuntu
# @stdout diagnostics logs
Linux::Apt::isPackageInstalled() {
  local package="$1"
  dpkg -l "${package}" | grep -Eq "^ii  ${package}"
}
