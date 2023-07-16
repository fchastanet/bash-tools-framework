#!/usr/bin/env bash

# echo the sh file only if not present in the list provided as second parameter
# the shebang is automatically removed
# @param {String} file $1 the file to import
# @param {&String[]} compilerInjectFileOnceAlreadyImported $2 array of files
#   already imported (passed by reference)
# @return 1 if file that does not exist
Compiler::injectFileOnce() {
  local file="$1"
  local -n compilerInjectFileOnceAlreadyImported=$2

  if ! Array::contains "${file}" "${compilerInjectFileOnceAlreadyImported[@]}"; then
    if [[ ! -f "${file}" ]]; then
      (echo >&2 -e "${__ERROR_COLOR}\tImport ${file} does not exist${__RESET_COLOR}")
      return 1
    fi

    if [[ "${DEBUG:-0}" = "1" ]]; then
      (echo >&2 -e "${__DEBUG_COLOR}\tImporting ${file} ...${__RESET_COLOR}")
    fi
    Filters::catFileCleaned "${file}"
    compilerInjectFileOnceAlreadyImported+=("${file}")
  fi
}