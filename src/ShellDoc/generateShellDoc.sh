#!/usr/bin/env bash

# extract shDoc from file
#
# @param {String} $1 currentDir
# @param {String} $2 relativeFile
# @output the shell documentation in markdown format
ShellDoc::generateShellDoc() {
  local currentDir="$1"
  local relativeFile="$2"

  ShellDoc::installRequirementsIfNeeded
  (
    cd "${currentDir}" || exit 1
    "${FRAMEWORK_ROOT_DIR}/vendor/fchastanet.tomdoc.sh/tomdoc.sh" "${relativeFile}"
  )
}
