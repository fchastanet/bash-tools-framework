#!/usr/bin/env bash

# missingBashFileList this file will contain the files that are not available when checking them
# File::detectBashFile is used in conjunction with git ls-files
# typical case for missing file is when a file is marked as deleted but not staged
declare missingBashFileList
missingBashFileList=""
export missingBashFileList

# @description check if file provided is a bash file
# @arg $@ files:String[]
# @set missingBashFileList String temp filepath that contains eventual missing files
# @stdout filepath if Assert::bashFile succeed
# @see Assert::bashFile
File::detectBashFile() {
  local -a files=("$@")
  local file
  for file in "${files[@]}"; do
    if [[ ! -f "${file}" ]]; then
      if [[ -z "${missingBashFileList}" ]]; then
        missingBashFileList="$(mktemp -p "${TMPDIR:-/tmp}" -t bash-tools-detectBashFile-before-XXXXXX)"
      fi
      echo "${file}" >>"${missingBashFileList}"
      continue
    fi
    if Assert::bashFile "${file}"; then
      echo "${file}"
    fi
  done
}
