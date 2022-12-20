#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Array/contains.sh
source "${BATS_TEST_DIRNAME}/contains.sh"

function Array::contains { #@test
  declare -a tab=("elem1" "elem2" "elem3")

  run Array::contains "elem0" "${tab[@]}"
  # shellcheck disable=SC2154
  [[ "${status}" = "1" ]]
  run Array::contains "elem1" "${tab[@]}"
  [[ "${status}" = "0" ]]
  run Array::contains "elem3" "${tab[@]}"
  [[ "${status}" = "0" ]]
}
