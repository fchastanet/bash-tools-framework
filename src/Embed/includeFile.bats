#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/batsHeaders.sh"

# shellcheck source=src/Embed/includeFile.sh
source "${BATS_TEST_DIRNAME}/includeFile.sh"

setup() {
  export TMPDIR="${BATS_RUN_TMPDIR}"
  export PATH="${TMPDIR}/bin":${PATH}
}

function Embed::includeFile::binaryFile { #@test
  (
    echo "#!/bin/bash"
    Embed::includeFile "${BATS_TEST_DIRNAME}/testsData/binaryFile" "binaryFile"
  ) >"${BATS_RUN_TMPDIR}/fileIncluded"
  source "${BATS_RUN_TMPDIR}/fileIncluded"

  run binaryFile arg1 arg2

  assert_success
  assert_output "binaryFile arg1 arg2"
  [[ -x "${BATS_RUN_TMPDIR}/bin/binaryFile" ]]
  # shellcheck disable=SC2154
  [[ "${embed_file_binaryFile}" = "${BATS_RUN_TMPDIR}/bin/binaryFile" ]]
}

function Embed::includeFile::normalFile { #@test
  (
    echo "#!/bin/bash"
    Embed::includeFile "${BATS_TEST_DIRNAME}/testsData/normalFile" "normalFile"
  ) >"${BATS_RUN_TMPDIR}/fileIncluded"
  source "${BATS_RUN_TMPDIR}/fileIncluded"

  [[ ! -x "${BATS_RUN_TMPDIR}/bin/normalFile" ]]
  [[ "$(head -1 "${BATS_RUN_TMPDIR}/bin/normalFile")" = "normalFileContent" ]]
  # shellcheck disable=SC2154
  [[ "${embed_file_normalFile}" = "${BATS_RUN_TMPDIR}/bin/normalFile" ]]
}
