#!/usr/bin/env bash

# @description Initialize the missingBashFileList variable used by File::detectBashFile
# @set missingBashFileList String temp filepath that contains eventual missing files
# @noargs
File::detectBashFileInit() {
  local -a files=("$@")
  local file
  if [[ -n "${missingBashFileList}" ]]; then
    rm -f "${missingBashFileList}" || true
  fi
  missingBashFileList="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-detectBashFile-before-XXXXXX)"
  export -f File::detectBashFile
  export -f Assert::bashFile
  export missingBashFileList
}
