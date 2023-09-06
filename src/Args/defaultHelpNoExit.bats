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

function Args::defaultHelpNoExit::HelpHelpArg { #@test
  run Args::defaultHelpNoExit "Help" "--help" 2>&1
  assert_failure 1
  assert_output "Help"
}

function Args::defaultHelpNoExit::HelpShortHelpArg { #@test
  run Args::defaultHelpNoExit "Help" "arg1" "-h" "arg2" 2>&1
  assert_failure 1
  assert_output "Help"
}

function Args::defaultHelpNoExit::noHelpArg { #@test
  run Args::defaultHelpNoExit "Help" "arg1" "arg2" 2>&1
  assert_success
  assert_output ""
}
