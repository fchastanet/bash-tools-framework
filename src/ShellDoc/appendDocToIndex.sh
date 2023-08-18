#!/usr/bin/env bash

# @description add reference to index file (using docsify embed feature)
# @arg $1 indexFile:String
# @arg $2 mdRelativeFile:String
# @arg $3 title:String
ShellDoc::appendDocToIndex() {
  local indexFile="$1"
  local mdRelativeFile="$2"
  local title="$3"

  (
    echo "[${title}](${mdRelativeFile} ':include')"
    echo
  ) >>"${indexFile}"
}
