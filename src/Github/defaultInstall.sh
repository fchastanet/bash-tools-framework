#!/usr/bin/env bash

Github::defaultInstall() {
  local newSoftware="$1"
  local targetFile="$2"
  local version="$3"
  local installCallback=$4
  # shellcheck disable=SC2086
  if [[ "$(type -t ${installCallback})" = "function" ]]; then
    ${installCallback} "${newSoftware}" "${targetFile}" "${version}"
  else
    mkdir -p "$(dirname "${targetFile}")"
    mv "${newSoftware}" "${targetFile}"
    chmod +x "${targetFile}"
    hash -r
  fi
  rm -f "${newSoftware}" || true
}
