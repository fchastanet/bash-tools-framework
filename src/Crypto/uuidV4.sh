#!/usr/bin/env bash

Crypto_random_file_exists() {
  [[ -f /proc/sys/kernel/random/uuid ]]
}

# @description generate a UUID in version 4 format
# @exitcode 1 if neither /proc/sys/kernel/random/uuid nor uuidgen are available
# @stderr diagnostics information is displayed
Crypto::uuidV4() {
  if Crypto_random_file_exists; then
    cat /proc/sys/kernel/random/uuid
  elif Assert::commandExists uuidgen; then
    uuidgen -r
  else
    Log::displayError "unable to generate uuid on that system"
    return 1
  fi
}
