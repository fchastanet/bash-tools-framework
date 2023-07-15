#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"
srcDir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=src/Env/pathPrepend.sh
source "${BATS_TEST_DIRNAME}/pathPrepend.sh"

function setup() {
  PATH_BACKUP="${PATH}"
}

function teardown() {
  PATH="${PATH_BACKUP}"
}

function Env::pathPrepend::notPath { #@test
  Env::pathPrepend
  [[ "${PATH_BACKUP}" = "${PATH}" ]]
}

function Env::pathPrepend::notExistingPath { #@test
  Env::pathPrepend "/binaryPathNotExisting"
  [[ "${PATH_BACKUP}" = "${PATH}" ]]
}

function Env::pathPrepend::notExistingPreviously { #@test
  Env::pathPrepend "${BATS_TEST_DIRNAME}"
  [[ "${BATS_TEST_DIRNAME}:${PATH_BACKUP}" = "${PATH}" ]]
}

function Env::pathPrepend::multiple { #@test
  Env::pathPrepend "${vendorDir}" "${srcDir}"
  [[ "${srcDir}:${vendorDir}:${PATH_BACKUP}" = "${PATH}" ]]
}

function Env::pathPrepend::relative { #@test
  (
    cd "${BATS_TEST_DIRNAME}" || exit 1
    Env::pathPrepend ".."
    [[ "${srcDir}:${PATH_BACKUP}" = "${PATH}" ]]
  )
}
