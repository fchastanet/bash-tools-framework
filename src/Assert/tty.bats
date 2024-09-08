#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/tty.sh
source "${srcDir}/Assert/tty.sh"

teardown() {
  unstub_all
}

function Assert::tty_non_interactive { #@test
  stub tty '-s : exit 1'
  run Assert::tty
  assert_failure
  assert_output ""
}

function Assert::tty_force_interactive { #@test
  export INTERACTIVE=1
  run Assert::tty
  assert_success
  assert_output ""
}

function Assert::tty_force_non_interactive { #@test
  export NON_INTERACTIVE=1
  run Assert::tty
  assert_failure
  assert_output ""
}
