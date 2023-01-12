#!/usr/bin/env bash

Install::setUserRootCallback() {
  # shellcheck disable=SC2034 # $1 not used
  local FROM_FILE="$1"
  local DEST_FILE="$2"
  chown root:root "${DEST_FILE}"
}
