#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Args/removeIf.sh
source "${srcDir}/Array/removeIf.sh"

function Args::removeIf::noArgEmptyArray { #@test
  local -a myArray=()
  local status=0
  Array::removeIf myArray || status=$?
  [[ "${status}" = "1" ]]
  [[ "${#myArray[@]}" = "0" ]]
}

function Args::removeIf::noArgNonEmptyArray { #@test
  local -a myArray=("elem1")
  local status=0
  Array::removeIf myArray || status=$?
  [[ "${status}" = "1" ]]
  [[ "${#myArray[@]}" = "1" ]]
  [[ "${myArray[*]}" = "elem1" ]]
  [[ "${!myArray[*]}" = "0" ]]
}

function Args::removeIf::emptyArrayRemove1element { #@test
  local -a myArray=()
  function predicate1() {
    [[ "$1" = "elem1" ]] || return 1
  }
  local status=0
  Array::removeIf myArray predicate1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${#myArray[@]}" = "0" ]]
}

function Args::removeIf::removeIf1elementExists { #@test
  local -a myArray=("elem1")
  function predicate1() {
    [[ "$1" = "elem1" ]] || return 1
  }
  local status=0
  Array::removeIf myArray predicate1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${#myArray[@]}" = "0" ]]
}

function Args::removeIf::removeIf1elementNotExists { #@test
  local -a myArray=("elem2")
  local status=0
  function predicate1() {
    [[ "$1" = "elem1" ]] || return 1
  }
  Array::removeIf myArray predicate1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${#myArray[@]}" = "1" ]]
  [[ "${myArray[*]}" = "elem2" ]]
}

function Args::removeIf::removeIf1elementMultipleTimes { #@test
  local -a myArray=("elem1" "elemX" "elem2" "elemX" "elem3" "elemX" "elem4" "elemX" "elem5" "elemX")
  local status=0
  function predicateElemX() {
    [[ "$1" = "elemX" ]] || return 1
  }
  Array::removeIf myArray predicateElemX || status=$?
  [[ "${status}" = "0" ]]
  [[ "${#myArray[@]}" = "5" ]]
  [[ "${myArray[*]}" = "elem1 elem2 elem3 elem4 elem5" ]]
  [[ "${!myArray[*]}" = "0 1 2 3 4" ]]
}

function Args::removeIf::removeIfMultipleElements { #@test
  local -a myArray=("elem1" "elemX" "elem2" "elemX" "elem3" "elemX" "elem4" "elemX" "elem5" "elemX")
  local status=0
  function predicateElem1to5() {
    [[ "$1" =~ ^elem[1-5]$ ]] || return 1
  }
  Array::removeIf myArray predicateElem1to5 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${#myArray[@]}" = "5" ]]
  [[ "${myArray[*]}" = "elemX elemX elemX elemX elemX" ]]
  [[ "${!myArray[*]}" = "0 1 2 3 4" ]]
}
