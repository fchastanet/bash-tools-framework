#!/usr/bin/env bash

# remove verbose param
declare -a newParams=()
for param; do
  # shellcheck disable=SC2154
  [[ "${param}" == "${longArg}" || "${param}" == "${shortArg}" ]] || newParams+=("${param}")
done
set -- "${newParams[@]}"
