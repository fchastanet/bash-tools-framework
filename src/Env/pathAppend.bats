#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"
srcDir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=src/Env/pathAppend.sh
source "${BATS_TEST_DIRNAME}/pathAppend.sh"

function setup() {
  PATH_BACKUP="${PATH}"
}

function teardown() {
  PATH="${PATH_BACKUP}"
}

function Env::pathAppend::notPath { #@test
  Env::pathAppend
  [[ "${PATH_BACKUP}" = "${PATH}" ]]
}

function Env::pathAppend::notExistingPath { #@test
  Env::pathAppend "/binaryPathNotExisting"
  [[ "${PATH_BACKUP}" = "${PATH}" ]]
}

function Env::pathAppend::notExistingPreviously { #@test
  Env::pathAppend "${BATS_TEST_DIRNAME}"
  [[ "${PATH_BACKUP}:${BATS_TEST_DIRNAME}" = "${PATH}" ]]
}

function Env::pathAppend::multiple { #@test
  Env::pathAppend "${vendorDir}" "${srcDir}"
  [[ "${PATH_BACKUP}:${vendorDir}:${srcDir}" = "${PATH}" ]]
}

function Env::pathAppend::relative { #@test
  (
    cd "${BATS_TEST_DIRNAME}" || exit 1
    Env::pathAppend ".."
    [[ "${PATH_BACKUP}:${srcDir}" = "${PATH}" ]]
  )
}
