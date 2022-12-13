#!/usr/bin/env bash

# extract software version number
# @param $1 the command that will be called with --version parameter
Version::getCommandVersionFromPlainText() {
  local command="$1"
  local argVersion="${2:---version}"
  "${command}" "${argVersion}" 2>&1 |
    Version::parse # keep only version numbers
}
