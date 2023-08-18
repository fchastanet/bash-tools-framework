#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Embed/extractDirFromBase64.sh
source "${srcDir}/Compiler/Embed/extractDirFromBase64.sh"

function Compiler::Embed::extractDirFromBase64::empty { #@test
  run Compiler::Embed::extractDirFromBase64 "${BATS_TEST_TMPDIR}/base64" ""
  [[ -d "${BATS_TEST_TMPDIR}/base64" ]]
  assert_failure 1
  assert_output --partial "ERROR   - untar failure, invalid base64 string"
}

function Compiler::Embed::extractDirFromBase64::directory { #@test
  run Compiler::Embed::extractDirFromBase64 "${BATS_TEST_TMPDIR}/base64" \
    "$(
      cd "${BATS_TEST_DIRNAME}/testsData"
      tar -cz -O . | base64 -w 0
    )"
  assert_success
  assert_output ""
  [[ -d "${BATS_TEST_TMPDIR}/base64" ]]
  run diff "${BATS_TEST_TMPDIR}/base64" "${BATS_TEST_DIRNAME}/testsData"
  assert_success
  assert_output ""
}

function Compiler::Embed::extractDirFromBase64::createTargetDirectory { #@test
  run Compiler::Embed::extractDirFromBase64 "${BATS_TEST_TMPDIR}/targetDir/base64" \
    "$(
      cd "${BATS_TEST_DIRNAME}/testsData"
      tar -cz -O . | base64 -w 0
    )"
  assert_success
  assert_output ""
  [[ -d "${BATS_TEST_TMPDIR}/targetDir/base64" ]]
  run diff "${BATS_TEST_TMPDIR}/targetDir/base64" "${BATS_TEST_DIRNAME}/testsData"
  assert_success
  assert_output ""
}
