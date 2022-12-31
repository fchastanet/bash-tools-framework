#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Database/checkDsnFile.sh
source "${srcDir}/Database/checkDsnFile.sh"

function Database::checkDsnFile::fileNotFound { #@test
  run Database::checkDsnFile "notFound" 2>&1
  assert_failure 1
  assert_output --partial "ERROR   - dsn file notFound not found"
}

function Database::checkDsnFile::MissingHostname { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/testsData/dsn_missing_hostname.env" 2>&1
  assert_failure 1
  assert_output --partial "ERROR   - dsn file ${BATS_TEST_DIRNAME}/testsData/dsn_missing_hostname.env : HOSTNAME not provided"
}

function Database::checkDsnFile::WarningHostnameLocalhost { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/testsData/dsn_hostname_localhost.env" 2>&1
  assert_success
  assert_output --partial "WARN    - dsn file ${BATS_TEST_DIRNAME}/testsData/dsn_hostname_localhost.env : check that HOSTNAME should not be 127.0.0.1 instead of localhost"
}

function Database::checkDsnFile::MissingPort { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/testsData/dsn_missing_port.env" 2>&1
  assert_failure 1
  assert_output --partial "ERROR   - dsn file ${BATS_TEST_DIRNAME}/testsData/dsn_missing_port.env : PORT not provided"
}

function Database::checkDsnFile::InvalidPort { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/testsData/dsn_invalid_port.env" 2>&1
  assert_failure 1
  assert_output --partial "ERROR   - dsn file ${BATS_TEST_DIRNAME}/testsData/dsn_invalid_port.env : PORT invalid"
}

function Database::checkDsnFile::MissingUser { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/testsData/dsn_missing_user.env" 2>&1
  assert_failure 1
  assert_output --partial "ERROR   - dsn file ${BATS_TEST_DIRNAME}/testsData/dsn_missing_user.env : USER not provided"
}

function Database::checkDsnFile::MissingPassword { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/testsData/dsn_missing_password.env" 2>&1
  assert_failure 1
  assert_output --partial "ERROR   - dsn file ${BATS_TEST_DIRNAME}/testsData/dsn_missing_password.env : PASSWORD not provided"
}

function Database::checkDsnFile::Valid { #@test
  run Database::checkDsnFile "${BATS_TEST_DIRNAME}/testsData/dsn_valid.env" 2>&1
  assert_success
  assert_output ""
}
