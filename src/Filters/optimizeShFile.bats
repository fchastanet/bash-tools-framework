#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/optimizeShFile.sh
source "${BATS_TEST_DIRNAME}/optimizeShFile.sh"
# shellcheck source=src/Filters/removeEmptyLines.sh
source "${srcDir}/Filters/removeEmptyLines.sh"
# shellcheck source=src/Filters/commentLines.sh
source "${srcDir}/Filters/commentLines.sh"

function Filters::optimizeShFile::stdin { #@test
  echo -e "#!/bin/bash\n\nTEST\n\t\n" | {
    run Filters::optimizeShFile
    assert_output "TEST"
  }
}

function Filters::optimizeShFile::fromFile { #@test
  run Filters::optimizeShFile "${BATS_TEST_DIRNAME}/testsData/directive.sh"
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/optimizeShFile.directive.txt")"
}
