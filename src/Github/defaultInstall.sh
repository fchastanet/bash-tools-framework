#!/usr/bin/env bash

Github::defaultInstall() {
  local newSoftware="$1"
  local targetFile="$2"
  local version="$3"
  local installCallback=$4
  # shellcheck disable=SC2086
  mkdir -p "$(dirname "${targetFile}")"
  if [[ "$(type -t "${installCallback}")" = "function" ]]; then
    ${installCallback} "${newSoftware}" "${targetFile}" "${version}"
  else
    mv "${newSoftware}" "${targetFile}"
  fi
  chmod +x "${targetFile}"
  hash -r
  rm -f "${newSoftware}" || true
}
