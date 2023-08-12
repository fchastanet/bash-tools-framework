#!/usr/bin/env bash

# @description append directories to the PATH environment variable
# @arg $@ args:String[] list of directories to append
# @set PATH update PATH with the directories appended
Env::pathAppend() {
  local arg
  for arg in "$@"; do
    if [[ -d "${arg}" && ":${PATH}:" != *":${arg}:"* ]]; then
      PATH="${PATH:+"${PATH}:"}$(realpath "${arg}")"
    fi
  done
}
