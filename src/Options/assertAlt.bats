#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Options/assertAlt.sh
source "${srcDir}/Options/assertAlt.sh"

function Options::assertAlt::Empty { #@test
  run Options::assertAlt ""
  assert_failure
  assert_output ""
}

function Options::assertAlt::@ { #@test
  run Options::assertAlt "@"
  assert_failure
  assert_output ""
}

function Options::assertAlt::underscore { #@test
  run Options::assertAlt "--log_verbose"
  assert_failure
  assert_output ""
}

function Options::assertAlt::spaces { #@test
  run Options::assertAlt "--log verbose"
  assert_failure
  assert_output ""
}

function Options::assertAlt::Valid { #@test
  run Options::assertAlt "--log-verbose"
  assert_success
  assert_output ""
}
