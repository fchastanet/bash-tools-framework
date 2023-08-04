#!/usr/bin/env bash

# missingBashFileList this file will contain the files that are not available when checking them
# File::detectBashFile is used in conjunction with git ls-files
# typical case for missing file is when a file is marked as deleted but not staged
declare missingBashFileList
missingBashFileList=""
export missingBashFileList

File::detectBashFile() {
  local file="$1"

  if [[ ! -f "${file}" ]]; then
    if [[ -z "${missingBashFileList}" ]]; then
      missingBashFileList="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-buildBinFiles-before-XXXXXX)"
    fi
    echo "${file}" >>"${missingBashFileList}"
    return 0
  fi
  if Assert::bashFile "${file}"; then
    echo "${file}"
  fi
}
