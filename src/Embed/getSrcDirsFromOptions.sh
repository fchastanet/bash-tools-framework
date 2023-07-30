#!/usr/bin/env bash

# Find all INCLUDE directives
# @env getSrcDirsFromOptionsRegexp the regexp to use to detect the srcDir
#   arguments (default value: '^--src-dir|-s$'
Embed::getSrcDirsFromOptions() {
  while (($# > 0)); do
    if [[ "$1" =~ ${getSrcDirsFromOptionsRegexp:-^--src-dir|-s$} ]]; then
      shift || true
      echo "$1"
    fi
    shift || true
  done
}
