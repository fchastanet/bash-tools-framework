#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Embed/extractFileFromBase64.sh
source "${srcDir}/Embed/extractFileFromBase64.sh"
# shellcheck source=src/Env/pathPrepend.sh
source "${srcDir}/Env/pathPrepend.sh"

function Embed::extractFileFromBase64::empty { #@test
  run Embed::extractFileFromBase64 "${BATS_TEST_TMPDIR}/base64" ""
  assert_success
  assert_output ""
  [[ -x "${BATS_TEST_TMPDIR}/base64" ]]
  run cat "${BATS_TEST_TMPDIR}/base64"
  assert_success
  assert_output ""
}

function Embed::extractFileFromBase64::binaryFile { #@test
  run Embed::extractFileFromBase64 "${BATS_TEST_TMPDIR}/base64" "$(base64 -w 0 "${BATS_TEST_DIRNAME}/testsData/binaryFile")"
  assert_success
  assert_output ""
  [[ -x "${BATS_TEST_TMPDIR}/base64" ]]
  run diff "${BATS_TEST_TMPDIR}/base64" "${BATS_TEST_DIRNAME}/testsData/binaryFile"
  assert_success
  assert_output ""
}

function Embed::extractFileFromBase64::createTargetDirectory { #@test
  run Embed::extractFileFromBase64 "${BATS_TEST_TMPDIR}/targetDir/base64" "$(base64 -w 0 "${BATS_TEST_DIRNAME}/testsData/binaryFile")"
  assert_success
  assert_output ""
  [[ -x "${BATS_TEST_TMPDIR}/targetDir/base64" ]]
  run diff "${BATS_TEST_TMPDIR}/targetDir/base64" "${BATS_TEST_DIRNAME}/testsData/binaryFile"
  assert_success
  assert_output ""
}
