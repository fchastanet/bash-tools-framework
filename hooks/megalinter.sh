#!/bin/bash

set -o errexit
set -o pipefail

declare image="$1"
shift || true

if (($# == 0)); then
  echo >&2 "No files staged, considering full scan is needed"
  ./bin/megalinter \
    --image "${image}" \
    --fix
else
  echo "$@"
  ./bin/megalinter \
    --image "${image}" \
    --fix \
    "$@"
fi
