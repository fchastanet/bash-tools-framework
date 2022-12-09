#!/usr/bin/env bash

# Checks if file can be created in folder
# The file does not need to exist
Assert::fileWritable() {
  local file="$1"
  local dir
  dir="$(dirname "${file}")"

  [[ -w "${dir}" ]]
}
