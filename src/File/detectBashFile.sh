#!/usr/bin/env bash

# missingBashFileList this file will contain the files that are not available when checking them
# File::detectBashFile is used in conjunction with git ls-files
# typical case for missing file is when a file is marked as deleted but not staged
declare missingBashFileList
missingBashFileList="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-buildBinFiles-before-XXXXXX)"
export missingBashFileList

File::detectBashFile() {
  file="$1"
  if [[ ! -f "${file}" ]]; then
    echo "${file}" >>"${missingBashFileList}"
  else
    awk 'FNR==1{if ($0~"^#!.*bash") print FILENAME}' "${file}"
  fi
}

export -f File::detectBashFile
