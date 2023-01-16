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
  [[ ${#allDepsResult[@]} = 4 ]]
  [[ "$(declare -p allDepsResultSeen)" = 'declare -A allDepsResultSeen=([Install4]="stored" [Install2]="stored" [Install3]="stored" [Install1]="stored" )' ]]
  [[ "$(declare -p allDepsResult)" = 'declare -a allDepsResult=([0]="Install2" [1]="Install3" [2]="Install4" [3]="Install1")' ]]
}

function Profiles::allDepsRecursiveMissingDependencies { #@test
  # shellcheck disable=SC2317
  testWithArrays() {
    declare -Ag allDepsResultSeen=()
    declare -ag allDepsResult=()
    Profiles::allDepsRecursive \
      "${BATS_TEST_DIRNAME}/testsData/allDepsRecursive/installScripts" "your software selection" \
      "Install5"
    declare -p allDepsResultSeen >"${TMPDIR}/allDepsResultSeen.txt"
    declare -p allDepsResult >"${TMPDIR}/allDepsResult.txt"
  }

  run testWithArrays
  assert_line --index 0 --partial "SKIPPED - ${BATS_TEST_DIRNAME}/testsData/allDepsRecursive/installScripts/Install6MissingDependencies.sh does not define the function installScripts_Install6MissingDependencies_dependencies"
  assert_line --index 1 --partial "INFO    - Install5 is a dependency of your software selection"

  [[ "$(cat "${TMPDIR}/allDepsResultSeen.txt")" = 'declare -A allDepsResultSeen=([Install5]="stored" )' ]]
  [[ "$(cat "${TMPDIR}/allDepsResult.txt")" = 'declare -a allDepsResult=([0]="Install5")' ]]
}
