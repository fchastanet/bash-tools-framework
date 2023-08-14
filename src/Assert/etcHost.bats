#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Assert/etcHost.sh
source "${srcDir}/Assert/etcHost.sh"

tearDown() {
  unset -f Assert::fileExists || true
  unset -f Assert::wsl || true
  unset -f Linux::Wsl::assertWindowsEtcHost || true
  unstub_all
}

function Assert::etcHost::fileNotExists { #@test
  Assert::fileExists() {
    return 1
  }
  run Assert::etcHost "host"
  assert_failure 1
  assert_output ""
}

function Assert::etcHost::hostNotFoundInLinuxEtcHost { #@test
  stub grep '-q -E "[[:space:]]host([[:space:]]|$)" /etc/hosts : exit 1'
  Assert::fileExists() {
    return 0
  }
  run Assert::etcHost "host"
  assert_failure 2
  assert_output --partial "Host host not configured in /etc/hosts"
}

function Assert::etcHost::hostFoundNoWsl { #@test
  stub grep '-q -E "[[:space:]]host([[:space:]]|$)" /etc/hosts : exit 0'
  Assert::fileExists() {
    return 0
  }
  Assert::wsl() {
    return 1
  }
  run Assert::etcHost "host"
  assert_success
  assert_output --partial "SUCCESS - Host host correctly configured"
}

function Assert::etcHost::hostFoundWslNotFoundInWindows { #@test
  stub grep '-q -E "[[:space:]]host([[:space:]]|$)" /etc/hosts : exit 0'
  Assert::fileExists() {
    return 0
  }
  Assert::wsl() {
    return 0
  }
  Linux::Wsl::assertWindowsEtcHost() {
    return 1
  }
  run Assert::etcHost "host"
  assert_failure 3
  assert_output ""
}

function Assert::etcHost::hostFoundInBoth { #@test
  stub grep '-q -E "[[:space:]]host([[:space:]]|$)" /etc/hosts : exit 0'
  Assert::fileExists() {
    return 0
  }
  Assert::wsl() {
    return 0
  }
  Linux::Wsl::assertWindowsEtcHost() {
    return 0
  }
  run Assert::etcHost "host"
  assert_success
  assert_output --partial "SUCCESS - Host host correctly configured"
}
