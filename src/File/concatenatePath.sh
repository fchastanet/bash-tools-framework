#!/usr/bin/env bash

File::concatenatePath() {
  local basePath="${1}"
  local subPath=${2}
  local fullPath="${basePath:+${basePath}/}${subPath}"

  realpath -m "${fullPath}" 2>/dev/null
}
