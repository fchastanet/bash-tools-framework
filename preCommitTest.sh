#!/bin/bash

if [[ ! -f "$(pwd)/test.sh" ]]; then
  echo >&2 "test.sh does not exist in this repository"
  exit 1
fi

exec "$(pwd)/test.sh" "$@"
