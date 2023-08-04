#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

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
