#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)/batsHeaders.sh"

# shellcheck source=src/Embed/includeDir.sh
source "${BATS_TEST_DIRNAME}/includeDir.sh"

setup() {
  export TMPDIR="${BATS_RUN_TMPDIR}"
}

function Embed::includeDir::testsData { #@test
  (
    echo "#!/bin/bash"
    Embed::includeDir "${BATS_TEST_DIRNAME}/testsData" "testsData"
  ) >"${BATS_RUN_TMPDIR}/dirIncluded"
  source "${BATS_RUN_TMPDIR}/dirIncluded"

  [[ -d "${BATS_RUN_TMPDIR}/testsData" ]]
  [[ -f "${BATS_RUN_TMPDIR}/testsData/binaryFile" ]]
  [[ -f "${BATS_RUN_TMPDIR}/testsData/normalFile" ]]
  # shellcheck disable=SC2154
  [[ "${embed_dir_testsData}" = "${BATS_RUN_TMPDIR}/testsData" ]]
}
