#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/extractUniqueFrameworkFunctions.sh
source "${BATS_TEST_DIRNAME}/extractUniqueFrameworkFunctions.sh"
# shellcheck source=/src/Filters/commentLines.sh
source "${srcDir}/Filters/commentLines.sh"
# shellcheck source=/src/Filters/bashFrameworkFunctions.sh
source "${srcDir}/Filters/bashFrameworkFunctions.sh"
# shellcheck source=/src/Filters/uniqUnsorted.sh
source "${srcDir}/Filters/uniqUnsorted.sh"

function Compiler::extractUniqueFrameworkFunctions { #@test
  run Compiler::extractUniqueFrameworkFunctions "${BATS_TEST_DIRNAME}/extractUniqueFrameworkFunctions.sh"
  assert_success
  assert_lines_count 4
  assert_line --index 0 'Compiler::extractUniqueFrameworkFunctions'
  assert_line --index 1 'Filters::commentLines'
  assert_line --index 2 'Filters::bashFrameworkFunctions'
  assert_line --index 3 'Filters::uniqUnsorted'
}

function Compiler::extractUniqueFrameworkFunctions::self { #@test
  Compiler::extractUniqueFrameworkFunctions "${BATS_TEST_DIRNAME}/testsData/frameworkLint" \
    >"${BATS_TEST_TMPDIR}/frameworkLint"
  run cat "${BATS_TEST_TMPDIR}/frameworkLint"
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/frameworkLint.expectedList")"
}
