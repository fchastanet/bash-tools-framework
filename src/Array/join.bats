#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Array/join.sh
source "${BATS_TEST_DIRNAME}/join.sh"

function Array::join_no_arg { #@test
  run Array::join
  assert_success
  assert_output ""
}

function Array::join_one_arg { #@test
  run Array::join ","
  assert_success
  assert_output ""
}

function Array::join_two_args { #@test
  run Array::join "," "arg1" "arg2"
  assert_success
  assert_output "arg1,arg2"
}

function Array::join_three_args { #@test
  run Array::join "," "arg1" "arg2" "arg3"
  assert_success
  assert_output "arg1,arg2,arg3"
}

function Array::join_three_args_separator_multiple_characters { #@test
  run Array::join ", " "arg1" "arg2" "arg3"
  assert_success
  assert_output "arg1, arg2, arg3"
}
