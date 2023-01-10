#!/usr/bin/env bash

Install::setRootExecutableCallback() {
  # shellcheck disable=SC2034
  local FROM_FILE="$1"
  local DEST_FILE="$2"
  chown root:root "${DEST_FILE}"
  chmod +x "${DEST_FILE}"
}
