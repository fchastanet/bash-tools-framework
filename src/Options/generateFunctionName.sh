#!/usr/bin/env bash

# @description generate function name based on an UUID version 4 for given option name
# @exitcode 1 if neither /proc/sys/kernel/random/uuid nor uuidgen are available
# @stderr diagnostics information is displayed
Options::generateFunctionName() {
  local optionName="$1"
  local uuid
  uuid=$(Crypto::uuidV4 | sed -E -e 's/-//g') || return 1
  echo "${optionName}${uuid^}"
}
