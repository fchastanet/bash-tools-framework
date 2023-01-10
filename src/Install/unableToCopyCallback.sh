#!/usr/bin/env bash

Install::unableToCopyCallback() {
  local FROM_DIR="$1"
  local FILENAME="$2"
  local DEST_FILE="$3"
  Log::fatal "unable to copy file '${FROM_DIR#"${ROOT_DIR}/"}/${FILENAME}' to '${DEST_FILE}'"
}
