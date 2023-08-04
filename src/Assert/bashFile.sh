#!/usr/bin/env bash

Assert::bashFile() {
  local file="$1"
  local head=""
  if [[ ! -f "${file}" ]]; then
    return 2
  fi
  head="$(head -n 1 "${file}")"
  [[ "${head}" =~ ^#\!.*bash ]]
}
