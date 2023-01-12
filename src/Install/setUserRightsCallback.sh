#!/usr/bin/env bash

Install::setUserRightsCallback() {
  # shellcheck disable=SC2034 # $1 not used
  local FROM_FILE="$1"
  local DEST_FILE="$2"
  local USER_NAME="${3:-${USERNAME:-root}}"
  local USER_GROUP="${4:-${USERGROUP:-root}}"

  chown "${USER_NAME}":"${USER_GROUP}" "${DEST_FILE}"
}
