#!/usr/bin/env bash

File::detectBashFileInit
# shellcheck disable=SC2154
git ls-files --exclude-standard -c -o -m |
  LC_ALL=C.UTF-8 xargs -r -P0 -n 10 bash -c 'File::detectBashFile "$@"' 'arg0' |
  xargs -r "${commandToApply[@]}"
