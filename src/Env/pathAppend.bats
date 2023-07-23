#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

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
