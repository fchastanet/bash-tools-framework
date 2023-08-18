#!/usr/bin/env bash

# @description compare 2 version numbers
# @arg $1 version1:String version 1
# @arg $2 version2:String version 2
# @exitcode 0 if equal
# @exitcode 1 if version1 > version2
# @exitcode 2 else
Version::compare() {
  if [[ "$1" = "$2" ]]; then
    return 0
  fi
  local IFS=.
  # shellcheck disable=2206
  local i ver1=($1) ver2=($2)
  # fill empty fields in ver1 with zeros
  for ((i = ${#ver1[@]}; i < ${#ver2[@]}; i++)); do
    ver1[i]=0
  done
  for ((i = 0; i < ${#ver1[@]}; i++)); do
    if [[ -z "${ver2[i]+unset}" ]] || [[ -z ${ver2[i]} ]]; then
      # fill empty fields in ver2 with zeros
      ver2[i]=0
    fi
    if ((10#${ver1[i]} > 10#${ver2[i]})); then
      return 1
    fi
    if ((10#${ver1[i]} < 10#${ver2[i]})); then
      return 2
    fi
  done
  return 0
}
