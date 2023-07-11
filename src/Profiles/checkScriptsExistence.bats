#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Profiles/checkScriptsExistence.sh
source "${srcDir}/Profiles/checkScriptsExistence.sh"

teardown() {
  unstub_all
}

function Profiles::checkScriptsExistenceNoScript { #@test
  run Profiles::checkScriptsExistence "${BATS_TEST_DIRNAME}/testsData/allDepsRecursive/installScripts" ".sh"
  assert_success
  assert_output ""
}

function Profiles::checkScriptsExistence1Script { #@test
  run Profiles::checkScriptsExistence "${BATS_TEST_DIRNAME}/testsData/allDepsRecursive/installScripts" \
    ".sh" "Install1"
  assert_success
  assert_output ""
}

function Profiles::checkScriptsExistence2Scripts { #@test
  run Profiles::checkScriptsExistence "${BATS_TEST_DIRNAME}/testsData/allDepsRecursive/installScripts" \
    ".sh" "Install1" "Install2"
  assert_success
  assert_output ""
}

function Profiles::checkScriptsExistence3ScriptsThirdScriptMissing { #@test
  run Profiles::checkScriptsExistence "${BATS_TEST_DIRNAME}/testsData/allDepsRecursive/installScripts" \
    ".sh" "Install1" "Install3" "NotExist"
  assert_failure 1
  assert_output --partial "FATAL   - script NotExist doesn't exist"
}
