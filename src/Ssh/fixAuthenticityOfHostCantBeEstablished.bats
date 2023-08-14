#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Ssh/fixAuthenticityOfHostCantBeEstablished.sh
source "${srcDir}/Ssh/fixAuthenticityOfHostCantBeEstablished.sh"

setup() {
  export HOME="${BATS_TEST_TMPDIR}"
  mkdir -p "${BATS_TEST_TMPDIR}/.ssh"
  touch "${BATS_TEST_TMPDIR}/.ssh/known_hosts"
}

teardown() {
  unstub_all
}

function Ssh::fixAuthenticityOfHostCantBeEstablished::sshKeygenFailure { #@test
  stub ssh-keygen '-R host : exit 1'
  run Ssh::fixAuthenticityOfHostCantBeEstablished "host"

  assert_failure 1
  assert_output ""
}

function Ssh::fixAuthenticityOfHostCantBeEstablished::sshKeyscanFailureButIgnored { #@test
  stub ssh-keygen '-R host : exit 0'
  stub ssh-keyscan 'host : exit 1'
  run Ssh::fixAuthenticityOfHostCantBeEstablished "host"

  assert_success
  assert_output ""
  [[ "$(cat "${BATS_TEST_TMPDIR}/.ssh/known_hosts")" = "" ]]
}

function Ssh::fixAuthenticityOfHostCantBeEstablished::success { #@test
  stub ssh-keygen '-R host : exit 0'
  stub ssh-keyscan 'host : echo host ; exit 0'
  run Ssh::fixAuthenticityOfHostCantBeEstablished "host"

  assert_success
  assert_output ""
  [[ "$(cat "${BATS_TEST_TMPDIR}/.ssh/known_hosts")" = "host" ]]
}
