#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Env/parseEnvFileArg.sh
source "${srcDir}/Env/parseEnvFileArg.sh"

function Env::parseEnvFileArg::noArg { #@test
  unset BASH_FRAMEWORK_ARGV
  run Env::parseEnvFileArg
  assert_success
  assert_lines_count 0
}

function Env::parseEnvFileArg::emptyArg { #@test
  export BASH_FRAMEWORK_ARGV=()
  run Env::parseEnvFileArg
  assert_success
  assert_lines_count 0
}

function Env::parseEnvFileArg::envFileEmpty { #@test
  export BASH_FRAMEWORK_ARGV=(--env-file)
  run Env::parseEnvFileArg
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "Env file not provided"
}

function Env::parseEnvFileArg::envFileInvalid { #@test
  export BASH_FRAMEWORK_ARGV=(--env-file "invalidFile")
  run Env::parseEnvFileArg
  assert_failure 1
  assert_lines_count 1
  assert_output --partial "Env file provided 'invalidFile' is invalid"
}

function Env::parseEnvFileArg::envFileValidSimpleArg { #@test
  export BASH_FRAMEWORK_ARGV=(--env-file "${BATS_TEST_DIRNAME}/testsData/.env")
  run Env::parseEnvFileArg
  assert_success
  assert_lines_count 1
  assert_output --partial "${BATS_TEST_DIRNAME}/testsData/.env"
}

function Env::parseEnvFileArg::envFileValidMultiple { #@test
  export BASH_FRAMEWORK_ARGV=(--env-file "${BATS_TEST_DIRNAME}/testsData/.env" --env-file "${BATS_TEST_DIRNAME}/testsData/.envForced")
  run Env::parseEnvFileArg
  assert_success
  assert_lines_count 2
  assert_output --partial "${BATS_TEST_DIRNAME}/testsData/.env"
  assert_output --partial "${BATS_TEST_DIRNAME}/testsData/.envForced"
}

function Env::parseEnvFileArg::envFileValidMultipleArgs { #@test
  export BASH_FRAMEWORK_ARGV=(--verbose --env-file "${BATS_TEST_DIRNAME}/testsData/.env" --output --help -vvv)
  run Env::parseEnvFileArg
  assert_success
  assert_lines_count 1
  assert_output --partial "${BATS_TEST_DIRNAME}/testsData/.env"
}
