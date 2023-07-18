#!/usr/bin/env bash

# print the resolved path relative to DIR
# @param {string} srcFile $1 the file to resolve
# @param {string} relativeTo $2 the directory
# @output the resolved path relative to DIR
# @note do not check for path existence
File::relativeToDir() {
  local srcFile="$1"
  local relativeTo="$2"

  realpath -m --relative-to="${relativeTo}" "${srcFile}"
}
