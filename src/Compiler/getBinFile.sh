#!/usr/bin/env bash

# @description extract BIN_FILE directive from srcFile
# create the folder of the target file
# @arg $1 srcFile:String the file to import
# @env FRAMEWORK_ROOT_DIR this variable can be used to define BIN_FILE value
# @exitcode 1 if the path is not a valid path
# @exitcode 2 if the path is a directory
# @stdout the final BIN_FILE path
# @stderr diagnostics information is displayed
Compiler::getBinFile() {
  local srcFile="$1"
  local binFile

  binFile="$(Filters::directiveValue "BIN_FILE" "${srcFile}" |
    sed -E 's/^#[^=]+=[ \t]*(.*)[ \t]*$/\1/' |
    FRAMEWORK_ROOT_DIR="${FRAMEWORK_ROOT_DIR}" envsubst ||
    :)"
  if [[ -z "${binFile}" ]]; then
    Log::displaySkipped "${srcFile} does not contains BIN_FILE directive"
    return 0
  fi
  if ! Assert::validPath "${binFile}"; then
    Log::displayError "${srcFile} does not define a valid BIN_FILE value: '${binFile}' is not a valid path"
    return 1
  fi
  if [[ -d "${binFile}" ]]; then
    Log::displayError "${srcFile} does not define a valid BIN_FILE value: '${binFile}' is a directory"
    return 2
  fi
  mkdir -p "$(dirname "${binFile}")" || true
  echo "${binFile}"
}
