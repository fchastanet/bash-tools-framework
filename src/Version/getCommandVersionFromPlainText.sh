#!/usr/bin/env bash

# @description extract software version number
# @arg $1 command:String the command that will be called with --version parameter
# @arg $2 argVersion:String  allows to override default --version parameter
Version::getCommandVersionFromPlainText() {
  local command="$1"
  local argVersion="${2:---version}"
  "${command}" "${argVersion}" 2>&1 |
    Version::parse # keep only version numbers
}
