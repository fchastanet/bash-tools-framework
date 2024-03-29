#!/usr/bin/env bash

# echo the sh file only if not present in the list provided as second parameter
# the shebang is automatically removed
# @arg $1 file:String the file to import
# @arg $2 compilerInjectFileOnceAlreadyImported:&String[] array of files
#   already imported (passed by reference)
# @exitcode 1 if file that does not exist

# @description echo the sh file's content only if not present in the list provided as second parameter
# the shebang is automatically removed
# the file will be added to the compilerInjectFileOnceAlreadyImported array passed by reference
#
# @arg $1 file:String
# @arg $2 compilerInjectFileOnceAlreadyImported:&String[] (passed by reference) file will not wbe included if present in this list
# @exitcode 1 if file doesn't exist
# @stdout file content if not in the compilerInjectFileOnceAlreadyImported list cleaned of shebang
# @stderr diagnostics information is displayed if file not found
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
