#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Array/clone.sh
source "${BATS_TEST_DIRNAME}/clone.sh"

function Array::clone { #@test
  declare -a tab=("elem1" "elem2" "elem3")

  Array::clone "tab" "newTab"
  [[ -n ${newTab+x} ]]

  newTab+=("elem4")
  [[ "${#tab[@]}" = "3" ]]
  [[ "${#newTab[@]}" = "4" ]]
  [[ "${newTab[3]}" = "elem4" ]]

  tab+=("elem5")
  [[ "${#tab[@]}" = "4" ]]
  [[ "${tab[3]}" = "elem5" ]]
  [[ "${#newTab[@]}" = "4" ]]
}
