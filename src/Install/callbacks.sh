#!/usr/bin/env bash

setUserRights() {
  local FROM_FILE="$1"
  local DEST_FILE="$2"
  local USER_NAME="${3:-${USERNAME:-root}}"
  local USER_GROUP="${4:-${USERGROUP:-root}}"

  chown "${USER_NAME}":"${USER_GROUP}" "${DEST_FILE}"
}

setUserRoot() {
  local FROM_FILE="$1"
  local DEST_FILE="$2"
  chown root:root "${DEST_FILE}"
}

setRootExecutable() {
  # shellcheck disable=SC2034
  local FROM_FILE="$1"
  local DEST_FILE="$2"
  chown root:root "${DEST_FILE}"
  chmod +x "${DEST_FILE}"
}

unableToCopy() {
  local FROM_DIR="$1"
  local FILENAME="$2"
  local DEST_FILE="$3"
  Log:fatal "unable to copy file '${FROM_DIR#"${ROOT_DIR}/"}/${FILENAME}' to '${DEST_FILE}'"
}
