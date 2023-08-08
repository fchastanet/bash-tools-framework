#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Args/remove.sh
source "${srcDir}/Array/remove.sh"

function Args::remove::noArg { #@test
  local -a myArray=()
  local status=0
  Array::remove myArray
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${#myArray[@]}" = "0" ]]
}

function Args::remove::emptyArrayRemove1element { #@test
  local -a myArray=()
  local status=0
  Array::remove myArray "elem1"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${#myArray[@]}" = "0" ]]
}

function Args::remove::remove1elementExists { #@test
  local -a myArray=("elem1")
  local status=0
  Array::remove myArray "elem1"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${#myArray[@]}" = "0" ]]
}

function Args::remove::remove1elementNotExists { #@test
  local -a myArray=("elem2")
  local status=0
  Array::remove myArray "elem1"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${#myArray[@]}" = "1" ]]
  [[ "${myArray[*]}" = "elem2" ]]
}

function Args::remove::remove1elementMultipleTimes { #@test
  local -a myArray=("elem1" "elemX" "elem2" "elemX" "elem3" "elemX" "elem4" "elemX" "elem5" "elemX")
  local status=0
  Array::remove myArray "elemX"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${#myArray[@]}" = "5" ]]
  [[ "${myArray[*]}" = "elem1 elem2 elem3 elem4 elem5" ]]
  [[ "${!myArray[*]}" = "0 1 2 3 4" ]]
}

function Args::remove::removeMultipleElements { #@test
  local -a myArray=("elem1" "elemX" "elem2" "elemX" "elem3" "elemX" "elem4" "elemX" "elem5" "elemX")
  local status=0
  Array::remove myArray "elem1" "elem2" "elem3" "elem4" "elem5"
  status=$?
  [[ "${status}" = "0" ]]
  [[ "${#myArray[@]}" = "5" ]]
  [[ "${myArray[*]}" = "elemX elemX elemX elemX elemX" ]]
  [[ "${!myArray[*]}" = "0 1 2 3 4" ]]
}
