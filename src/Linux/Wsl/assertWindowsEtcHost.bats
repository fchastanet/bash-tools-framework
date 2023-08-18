#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Linux/Wsl/assertWindowsEtcHost.sh
source "${srcDir}/Linux/Wsl/assertWindowsEtcHost.sh"

setup() {
  export BASH_FRAMEWORK_LOG_FILE=""
}

tearDown() {
  unset -f Assert::fileExists || true
  unset -f Assert::wsl || true
  unset -f Linux::Wsl::assertWindowsEtcHost || true
  unstub_all
}

function Linux::Wsl::assertWindowsEtcHost::fileNotExists { #@test
  Assert::fileExists() {
    return 1
  }
  run Linux::Wsl::assertWindowsEtcHost "host"
  assert_failure 1
  assert_output ""
}

function Linux::Wsl::assertWindowsEtcHost::hostNotFound { #@test
  stub \
    dos2unix '* : exit 0' \
    grep '-q -E "[[:space:]]host([[:space:]]|$) : exit 1'
  Assert::fileExists() {
    return 0
  }
  run Linux::Wsl::assertWindowsEtcHost "host"
  assert_failure 1
  assert_output --partial "Host host not configured in windows host"
}

function Linux::Wsl::assertWindowsEtcHost::hostFound { #@test
  mkdir -p "${BATS_TEST_TMPDIR}/Windows/System32/drivers/etc"
  touch "${BATS_TEST_TMPDIR}/Windows/System32/drivers/etc/hosts"
  dos2unix() {
    return 0
  }
  grep() {
    return 0
  }
  Assert::fileExists() {
    return 0
  }
  BASE_MNT_C="${BATS_TEST_TMPDIR}" run Linux::Wsl::assertWindowsEtcHost "host"
  assert_success
  assert_output ""
}
