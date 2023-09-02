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

function Options::sourceFunction::functionName { #@test
  mkdir -p "${TMPDIR}/src/Options"
  cp "${BATS_TEST_DIRNAME}/testsData/simpleFunction.sh" \
    "${TMPDIR}/src/Options/simpleFunction.sh"
  local status=0
  Options::sourceFunction "Options::simpleFunction" \
    >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
  run Options::simpleFunction
  assert_success
  assert_output "simpleFunction"
}
