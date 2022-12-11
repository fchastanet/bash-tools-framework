#!/usr/bin/env bash

# default callback called to get a version of a software
Version::getCommandVersionFromJson() {
  local command="$1"
  local argVersion="${2:---version}"
  "${command}" "${argVersion}" 2>&1 |
    jq -r ".tag_name" | # Get tag line
    Version::parse      # keep only version numbers
}
