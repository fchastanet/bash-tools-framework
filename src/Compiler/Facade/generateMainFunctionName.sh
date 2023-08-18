#!/usr/bin/env bash

# @description generate main function name based on an UUID version 4
# @exitcode 1 if neither /proc/sys/kernel/random/uuid nor uuidgen are available
# @stderr diagnostics information is displayed
Compiler::Facade::generateMainFunctionName() {
  local uuid
  uuid=$(Crypto::uuidV4) || return 1
  echo "facade_main_${uuid}" | sed -E -e 's/-//g'
}
