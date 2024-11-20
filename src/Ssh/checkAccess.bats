#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Ssh/checkAccess.sh
source "${srcDir}/Ssh/checkAccess.sh"

setup() {
  export HOME="${BATS_TEST_TMPDIR}"
  mkdir -p "${BATS_TEST_TMPDIR}/.ssh"
}

teardown() {
  unstub_all
}

function Ssh::checkAccess::missingHost { #@test
  run Ssh::checkAccess

  assert_failure 2
  assert_output --partial "ERROR   - You must provide a host as first argument"
}

function Ssh::checkAccess::sshFailure { #@test
  stub ssh '-q -o PubkeyAuthentication=yes -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no -o ChallengeResponseAuthentication=no host exit : exit 1'
  run Ssh::checkAccess "host"

  assert_failure 1
  assert_output --partial "INFO    - Checking host can be accessed non interactively using ssh"
}

function Ssh::checkAccess::hostOnlySshSuccess { #@test
  stub ssh '-q -o PubkeyAuthentication=yes -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no -o ChallengeResponseAuthentication=no host exit : exit 0'
  run Ssh::checkAccess "host"

  assert_success
  assert_output --partial "INFO    - Checking host can be accessed non interactively using ssh"
}

function Ssh::checkAccess::MultipleArgsSshSuccess { #@test
  stub ssh '-q -o PubkeyAuthentication=yes -o PasswordAuthentication=no -o KbdInteractiveAuthentication=no -o ChallengeResponseAuthentication=no host arg1 arg2 exit : exit 0'
  run Ssh::checkAccess "host" arg1 arg2

  assert_success
  assert_output --partial "INFO    - Checking host can be accessed non interactively using ssh"
}
