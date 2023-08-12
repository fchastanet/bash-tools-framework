#!/usr/bin/env bash

# @description print the resolved path relative to DIR
# do not check for path existence
# @arg $1 srcFile:string the file to resolve
# @arg $2 relativeTo:string the directory
# @stdout the resolved path relative to DIR
File::relativeToDir() {
  local srcFile="$1"
  local relativeTo="$2"

  realpath -m --relative-to="${relativeTo}" "${srcFile}"
}
