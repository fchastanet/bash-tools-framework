#!/usr/bin/env bash

# missingBashFileList this file will contain the files that are not available when checking them
# File::detectBashFile is used in conjunction with git ls-files
# typical case for missing file is when a file is marked as deleted but not staged
declare missingBashFileList
missingBashFileList="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-buildBinFiles-before-XXXXXX)"
export missingBashFileList

File::detectBashFile() {
  local file="$1"
  local head=""
  if [[ ! -f "${file}" ]]; then
    echo "${file}" >>"${missingBashFileList}"
    return 1
  fi
  head="$(head -n 1 "${file}")"
  [[ "${head}" =~ ^#!.*bash ]]
}

export -f File::detectBashFile
