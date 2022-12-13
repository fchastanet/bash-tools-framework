#!/usr/bin/env bash

# add reference to index file
# @param {String} $1 indexFile
# @param {String} $2 mdRelativeFile
# @param {String} $3 title
ShellDoc::appendDocToIndex() {
  local indexFile="$1"
  local mdRelativeFile="$2"
  local title="$3"

  echo "* [${title}](${mdRelativeFile})" >>"${indexFile}"
}
