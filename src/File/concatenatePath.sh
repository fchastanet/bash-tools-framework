#!/usr/bin/env bash

# @description concatenate 2 paths and ensure the path is correct using realpath -m
# @arg $1 basePath:String
# @arg $2 subPath:String
# @require Linux::requireRealpathCommand
File::concatenatePath() {
  local basePath="$1"
  local subPath="$2"
  local fullPath="${basePath:+${basePath}/}${subPath}"

  realpath -m "${fullPath}" 2>/dev/null
}
