#!/usr/bin/env bash

# shellcheck source=bash-framework/_bootstrap.sh
BASH_FRAMEWORK_ENV_FILEPATH="" source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/bash-framework/_bootstrap.sh" || exit 1
set +o errexit

import bash-framework/Array

function framework_is_loaded { #@test
  [[ "${BASH_FRAMEWORK_INITIALIZED}" = "1" ]]
}

function Array_contains { #@test
  declare -a tab=("elem1" "elem2" "elem3")

  Array::contains "elem0" "${tab[@]}"
  # shellcheck disable=SC2154
  [[ "${status}" = "1" ]]
  Array::contains "elem1" "${tab[@]}"
  [[ "${status}" = "0" ]]
  Array::contains "elem3" "${tab[@]}"
  [[ "${status}" = "0" ]]
}
