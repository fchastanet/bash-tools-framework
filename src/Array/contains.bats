#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Array/contains.sh
source "${BATS_TEST_DIRNAME}/contains.sh"

function Array::contains { #@test
  declare -a tab=("elem1" "elem2" "elem3")

  run Array::contains "elem0" "${tab[@]}"
  assert_failure 1
  run Array::contains "elem1" "${tab[@]}"
  assert_success
  run Array::contains "elem3" "${tab[@]}"
  assert_success
}
