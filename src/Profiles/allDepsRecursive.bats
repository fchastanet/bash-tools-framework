#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Profiles/allDepsRecursive.sh
source "${srcDir}/Profiles/allDepsRecursive.sh"

teardown() {
  unstub_all
}

function Profiles::allDepsRecursiveNoDeps { #@test
  Profiles::allDepsRecursive \
    "${BATS_TEST_DIRNAME}/testsData" "your software selection"

  [[ -z "${output}" ]]
  [[ ${#allDepsResultSeen[@]} = 0 ]]
  [[ ${#allDepsResult[@]} = 0 ]]
}

function Profiles::allDepsRecursiveOK { #@test
  Profiles::allDepsRecursive \
    "${BATS_TEST_DIRNAME}/testsData/allDepsRecursive/installScripts" "your software selection" \
    "Install1"
  [[ ${#allDepsResultSeen[@]} = 4 ]]
  [[ "${allDepsResultSeen["Install1"]}" = "stored" ]]
  [[ "${allDepsResultSeen["Install2"]}" = "stored" ]]
  [[ "${allDepsResultSeen["Install3"]}" = "stored" ]]
  [[ "${allDepsResultSeen["Install4"]}" = "stored" ]]
  [[ ${#allDepsResult[@]} = 4 ]]
  [[ "${allDepsResult[0]}" = "Install2" ]]
  [[ "${allDepsResult[1]}" = "Install3" ]]
  [[ "${allDepsResult[2]}" = "Install4" ]]
  [[ "${allDepsResult[3]}" = "Install1" ]]
}

function Profiles::allDepsRecursiveMissingDependencies { #@test
  # shellcheck disable=SC2317
  testWithArrays() {
    declare -Ag allDepsResultSeen=()
    declare -ag allDepsResult=()
    Profiles::allDepsRecursive \
      "${BATS_TEST_DIRNAME}/testsData/allDepsRecursive/installScripts" "your software selection" \
      "Install5"
    declare -p allDepsResultSeen >"${BATS_TEST_TMPDIR}/allDepsResultSeen.txt"
    declare -p allDepsResult >"${BATS_TEST_TMPDIR}/allDepsResult.txt"
  }

  run testWithArrays
  assert_line --index 0 --partial "SKIPPED - ${BATS_TEST_DIRNAME}/testsData/allDepsRecursive/installScripts/Install6MissingDependencies.sh does not define the function installScripts_Install6MissingDependencies_dependencies"
  assert_line --index 1 --partial "INFO    - Install5 is a dependency of your software selection"

  [[ "$(cat "${BATS_TEST_TMPDIR}/allDepsResultSeen.txt")" = 'declare -A allDepsResultSeen=([Install5]="stored" )' ]]
  [[ "$(cat "${BATS_TEST_TMPDIR}/allDepsResult.txt")" = 'declare -a allDepsResult=([0]="Install5")' ]]
}
