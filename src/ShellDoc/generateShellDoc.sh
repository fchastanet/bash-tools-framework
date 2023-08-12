#!/usr/bin/env bash

# @description extract shDoc from file
#
# @arg $1 file:String
# @stdout the shell documentation in markdown format
ShellDoc::generateShellDoc() {
  local file="$1"

  ShellDoc::installRequirementsIfNeeded
  (
    "${FRAMEWORK_VENDOR_DIR}//shdoc/shdoc" <"${file}" || {
      Log::displayError "parse error of file ${file}"
      return 0
    }
  ) || true
}
