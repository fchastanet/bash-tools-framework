#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Options/_bats.sh
source "${srcDir}/Options/_bats.sh"

# shellcheck source=src/Options/__all.sh
source "${srcDir}/Options/__all.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
  export _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
}

function Options::generateFunction::functionNameEmpty { #@test
  local status=0
  Options::generateFunction "" "simpleFunction" "${BATS_TEST_DIRNAME}/testsData" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  testCommand "generateFunction.functionNameEmpty.sh" "Options::simpleFunction"
}

function Options::generateFunction::functionNameProvided { #@test
  local status=0
  run Options::generateFunction "myFunctionName" "simpleFunction" "${BATS_TEST_DIRNAME}/testsData"
  assert_success
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/generateFunction.functionNameProvided.sh")"
}
