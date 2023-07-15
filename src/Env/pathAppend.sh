#!/usr/bin/env bash

Env::pathAppend() {
  local arg
  for arg in "$@"; do
    if [[ -d "${arg}" && ":${PATH}:" != *":${arg}:"* ]]; then
      PATH="${PATH:+"${PATH}:"}$(realpath "${arg}")"
    fi
  done
}
