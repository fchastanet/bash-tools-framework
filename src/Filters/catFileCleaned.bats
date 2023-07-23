#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/catFileCleaned.sh
source "${BATS_TEST_DIRNAME}/catFileCleaned.sh"
# shellcheck source=src/Filters/trimEmptyLines.sh
source "${srcDir}/Filters/trimEmptyLines.sh"

function Filters::catFileCleaned::stdin { #@test
  echo -e "#!/bin/bash\nTEST" | {
    run Filters::catFileCleaned
    assert_output "TEST"
  }
}

function Filters::catFileCleaned::SeveralUppercase { #@test
  {
    run Filters::catFileCleaned
    assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/catFileCleaned.metadata.txt")"
  } <"${BATS_TEST_DIRNAME}/testsData/metadata.sh"
}
