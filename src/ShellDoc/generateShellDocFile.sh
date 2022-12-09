#!/usr/bin/env bash

# generate shell doc file
#
# @param {String} $1 currentDir
# @param {String} $2 relativeFile the file from which the markdown file will be generated
# @param {String} $3 targetDocFile the markdown file generated using tomdoc
# @return 0 if file has been generated, 1 if file is empty or error
# if generated doc is empty, targetDocFile is deleted if it was existing
ShellDoc::generateShellDocFile() {
  local currentDir="$1"
  local relativeFile="$2"
  local targetDocFile="$3"

  (
    local doc
    doc="$(ShellDoc::generateShellDoc "${currentDir}" "${relativeFile}")"
    if [[ -n "${doc}" ]]; then
      echo "${doc}" >"${targetDocFile}"
      return 0
    else
      # empty doc
      rm -f "${targetDocFile}" || true
      return 1
    fi
  )
}
