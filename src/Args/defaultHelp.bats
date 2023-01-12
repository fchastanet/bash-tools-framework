#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Args/defaultHelp.sh
source "${srcDir}/Args/defaultHelp.sh"
# shellcheck source=src/Args/showHelp.sh
source "${srcDir}/Args/showHelp.sh"
# shellcheck source=src/Args/defaultHelpNoExit.sh
source "${srcDir}/Args/defaultHelpNoExit.sh"

function Args::defaultHelp::noHelpNoArg { #@test
  run Args::defaultHelp 2>&1
  assert_success
  assert_output ""
}

function Args::defaultHelp::HelpNoArg { #@test
  run Args::defaultHelp "Help" 2>&1
  assert_success
  assert_output ""
}

function Args::defaultHelp::HelpAnyArg { #@test
  run Args::defaultHelp "Help" "arg1" "arg2" 2>&1
  assert_success
  assert_output ""
}

function Args::defaultHelp::HelpHelpArg { #@test
  run Args::defaultHelp "Help" "arg1" "--help" "arg2" 2>&1
  assert_success
  assert_output "Help"
}

function Args::defaultHelp::HelpShortHelpArg { #@test
  run Args::defaultHelp "Help" "arg1" "-h" "arg2" 2>&1
  assert_success
  assert_output "Help"
}

function Args::defaultHelp::CallbackAnyArg { #@test
  function callback() {
    # shellcheck disable=SC2317
    # should not be called
    echo "failure if called"
  }
  run Args::defaultHelp callback "arg1" "arg2" 2>&1
  assert_success
  assert_output ""
}

function Args::defaultHelp::CallbackHelpArg { #@test
  function callback() {
    # shellcheck disable=SC2317
    echo "callback $*"
  }
  run Args::defaultHelp callback "arg1" "--help" "arg2" 2>&1
  assert_success
  assert_output "callback --help -- arg1 arg2"
}

function Args::defaultHelp::CallbackShortHelpArg { #@test
  function callback() {
    # shellcheck disable=SC2317
    echo "callback $*"
  }
  run Args::defaultHelp callback "arg1" "-h" "arg2" 2>&1
  assert_success
  assert_output "callback -h -- arg1 arg2"
}
