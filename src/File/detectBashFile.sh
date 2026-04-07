#!/usr/bin/env bash

# missingBashFileList this file will contain the files that are not available when checking them
# File::detectBashFile is used in conjunction with git ls-files
# typical case for missing file is when a file is marked as deleted but not staged
declare missingBashFileList
missingBashFileList=""
export missingBashFileList

# @description check if file provided is a bash file
# @arg $@ files:String[]
# @prerequisite File::detectBashFileInit must have been called before to initialize the missingBashFileList variable
# @stdout filepath if Assert::bashFile succeed
# @see Assert::bashFile
File::detectBashFile() {
  local -a files=("$@")
  local file
  if [[ -z "${missingBashFileList}" ]]; then
    Log::displayError "File::detectBashFile: missingBashFileList variable is not set, you should call File::detectBashFileInit before using File::detectBashFile"
    return 1
  fi
  for file in "${files[@]}"; do
    if [[ ! -f "${file}" ]]; then
      echo "${file}" >>"${missingBashFileList}"
      continue
    fi
    if Assert::bashFile "${file}"; then
      echo "${file}"
    fi
  done
}
