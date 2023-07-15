#!/usr/bin/env bash

Env::pathPrepend() {
  local arg
  for arg in "$@"; do
    if [[ -d "${arg}" && ":${PATH}:" != *":${arg}:"* ]]; then
      PATH="$(realpath "${arg}"):${PATH}"
    fi
  done
}
