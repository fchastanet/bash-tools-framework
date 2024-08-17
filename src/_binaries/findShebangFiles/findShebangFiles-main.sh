#!/usr/bin/env bash

export -f File::detectBashFile
export -f Assert::bashFile

# shellcheck disable=SC2154
git ls-files --exclude-standard -c -o -m |
  xargs -r -L 1 -n 1 -I@ bash -c 'File::detectBashFile "@"' |
  xargs -r "${commandToApply[@]}"
