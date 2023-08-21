#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Env/parseVerboseArg.sh
source "${srcDir}/Env/parseVerboseArg.sh"
# shellcheck source=src/Framework/createTempFile.sh
source "${srcDir}/Framework/createTempFile.sh"
# shellcheck source=src/Log/_.sh
source "${srcDir}/Log/_.sh"

setup() {
  unset BASH_FRAMEWORK_ARGS_VERBOSE
  unset BASH_FRAMEWORK_DISPLAY_LEVEL
  TMPDIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR
}

function Env::parseVerboseArg::noArg { #@test
  unset BASH_FRAMEWORK_ARGV
  run Env::parseVerboseArg
  assert_success
  assert_lines_count 1
  assert_output --partial "${TMPDIR}/parseVerboseArgEnvFile"
  run cat "${output}"
  assert_lines_count 2
  assert_line --index 0 "BASH_FRAMEWORK_ARGS_VERBOSE_OPTION=''"
  assert_line --index 1 "BASH_FRAMEWORK_ARGS_VERBOSE=0"
}

function Env::parseVerboseArg::emptyArg { #@test
  export BASH_FRAMEWORK_ARGV=()
  run Env::parseVerboseArg
  assert_success
  assert_lines_count 1
  assert_output --partial "${TMPDIR}/parseVerboseArgEnvFile"
  run cat "${output}"
  assert_lines_count 2
  assert_line --index 0 "BASH_FRAMEWORK_ARGS_VERBOSE_OPTION=''"
  assert_line --index 1 "BASH_FRAMEWORK_ARGS_VERBOSE=0"
}

function Env::parseVerboseArg::verboseLongArg { #@test
  export BASH_FRAMEWORK_ARGV=(--verbose)
  run Env::parseVerboseArg
  assert_success
  assert_lines_count 1
  assert_output --partial "${TMPDIR}/parseVerboseArgEnvFile"
  run cat "${output}"
  assert_lines_count 3
  assert_line --index 0 "BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='--verbose'"
  assert_line --index 1 "BASH_FRAMEWORK_ARGS_VERBOSE=1"
  assert_line --index 2 "BASH_FRAMEWORK_DISPLAY_LEVEL=3"
}

function Env::parseVerboseArg::verboseShortArg { #@test
  export BASH_FRAMEWORK_ARGV=(-v)
  run Env::parseVerboseArg
  assert_success
  assert_lines_count 1
  assert_output --partial "${TMPDIR}/parseVerboseArgEnvFile"
  run cat "${output}"
  assert_lines_count 3
  assert_line --index 0 "BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='--verbose'"
  assert_line --index 1 "BASH_FRAMEWORK_ARGS_VERBOSE=1"
  assert_line --index 2 "BASH_FRAMEWORK_DISPLAY_LEVEL=3"
}

function Env::parseVerboseArg::vvArg { #@test
  export BASH_FRAMEWORK_ARGV=(-vv)
  run Env::parseVerboseArg
  assert_success
  assert_lines_count 1
  assert_output --partial "${TMPDIR}/parseVerboseArgEnvFile"
  run cat "${output}"
  assert_lines_count 3
  assert_line --index 0 "BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='-vv'"
  assert_line --index 1 "BASH_FRAMEWORK_ARGS_VERBOSE=2"
  assert_line --index 2 "BASH_FRAMEWORK_DISPLAY_LEVEL=4"
}

function Env::parseVerboseArg::vvvArg { #@test
  export BASH_FRAMEWORK_ARGV=(-vvv)
  run Env::parseVerboseArg
  assert_success
  assert_lines_count 1
  assert_output --partial "${TMPDIR}/parseVerboseArgEnvFile"
  run cat "${output}"
  assert_lines_count 3
  assert_line --index 0 "BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='-vvv'"
  assert_line --index 1 "BASH_FRAMEWORK_ARGS_VERBOSE=3"
  assert_line --index 2 "BASH_FRAMEWORK_DISPLAY_LEVEL=4"
}

function Env::parseVerboseArg::mixed { #@test
  export BASH_FRAMEWORK_ARGV=(--verbose -v -vv --help -h --env-file my-env-file -vvv)
  run Env::parseVerboseArg
  assert_success
  assert_lines_count 1
  assert_output --partial "${TMPDIR}/parseVerboseArgEnvFile"
  run cat "${output}"
  assert_lines_count 3
  assert_line --index 0 "BASH_FRAMEWORK_ARGS_VERBOSE_OPTION='-vvv'"
  assert_line --index 1 "BASH_FRAMEWORK_ARGS_VERBOSE=3"
  assert_line --index 2 "BASH_FRAMEWORK_DISPLAY_LEVEL=4"
}
