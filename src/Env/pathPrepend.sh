#!/usr/bin/env bash

# @description prepend directories to the PATH environment variable
# @arg $@ args:String[] list of directories to prepend
# @set PATH update PATH with the directories prepended
Env::pathPrepend() {
  local arg
  for arg in "$@"; do
    if [[ -d "${arg}" && ":${PATH}:" != *":${arg}:"* ]]; then
      PATH="$(realpath "${arg}"):${PATH}"
    fi
  done
}
