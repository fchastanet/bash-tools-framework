#!/usr/bin/env bash

# extract BIN_FILE directive from srcFile
# create the folder of the file
# @arg $1 file:String the file to import
# @exitcode 1 if the path is not a valid path
# @exitcode 2 if the path is a directory
Compiler::getBinFile() {
  local srcFile="$1"
  local BIN_FILE

  BIN_FILE="$(Filters::directiveValue "BIN_FILE" "${srcFile}" |
    sed -E 's/^#[^=]+=[ \t]*(.*)[ \t]*$/\1/' |
    FRAMEWORK_ROOT_DIR="${FRAMEWORK_ROOT_DIR}" envsubst ||
    :)"
  if [[ -z "${BIN_FILE}" ]]; then
    Log::displaySkipped "${srcFile} does not contains BIN_FILE directive"
    return 0
  fi
  if ! Assert::validPath "${BIN_FILE}"; then
    Log::displayError "${srcFile} does not define a valid BIN_FILE value: '${BIN_FILE}' is not a valid path"
    return 1
  fi
  if [[ -d "${BIN_FILE}" ]]; then
    Log::displayError "${srcFile} does not define a valid BIN_FILE value: '${BIN_FILE}' is a directory"
    return 2
  fi
  mkdir -p "$(dirname "${BIN_FILE}")" || true
  echo "${BIN_FILE}"
}
