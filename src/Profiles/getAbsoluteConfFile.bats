#!/usr/bin/env bash

FRAMEWORK_DIR="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)"
ROOT_DIR="${FRAMEWORK_DIR}"
vendorDir="${FRAMEWORK_DIR}/vendor"
srcDir="${FRAMEWORK_DIR}/src"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Profiles/getAbsoluteConfFile.sh
source "${srcDir}/Profiles/getAbsoluteConfFile.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
# shellcheck source=/src/File/concatenatePath.sh
source "${srcDir}/File/concatenatePath.sh"

setup() {
  BATS_TMP_DIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bats-$$-XXXXXX)"
  export TMPDIR="${BATS_TMP_DIR}"
  mkdir -p "${BATS_TMP_DIR}/home/.bash-tools/dsn" "${BATS_TMP_DIR}/conf/dsn2"
  cp "${BATS_TEST_DIRNAME}/testsData/dsn/"* "${BATS_TMP_DIR}/home/.bash-tools/dsn"
  cp "${BATS_TEST_DIRNAME}/testsData/dsn/default.local.env" "${BATS_TMP_DIR}/conf/dsn2/myConf.sh"
  export HOME="${BATS_TMP_DIR}/home"
}

teardown() {
  unstub_all
  rm -Rf "${BATS_TMP_DIR}" || true
}

function Profiles::getAbsoluteConfFile::EnvFileFromHome { #@test
  run Profiles::getAbsoluteConfFile "dsn" "default.local" "env"
  assert_success
  assert_output "${BATS_TMP_DIR}/home/.bash-tools/dsn/default.local.env"
}

function Profiles::getAbsoluteConfFile::ShFileFromHomeDefaultExtension { #@test
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"

  run Profiles::getAbsoluteConfFile "dsn" "otherInvalidExt2"
  assert_success
  assert_output "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"
}

function Profiles::getAbsoluteConfFile::ConfFolderDefault { #@test
  run Profiles::getAbsoluteConfFile "dsn" "default.local" "env"
  assert_success
  assert_output "${BATS_TMP_DIR}/home/.bash-tools/dsn/default.local.env"
}

function Profiles::getAbsoluteConfFile::Relative { #@test
  mkdir -p "${BATS_TMP_DIR}/home/.bash-tools/data"
  touch "${BATS_TMP_DIR}/home/.bash-tools/data/dsn_valid.env"

  run Profiles::getAbsoluteConfFile "../src/Profiles/testsData/dsn" "default.local" "env"

  assert_success
  assert_output "${BATS_TEST_DIRNAME}/testsData/dsn/default.local.env"
}

function Profiles::getAbsoluteConfFile::CurrentDir { #@test
  (
    cd "${BATS_TEST_DIRNAME}"
    export CURRENT_DIR="${BATS_TEST_DIRNAME}"
    run Profiles::getAbsoluteConfFile "testsData/dsn" "default.local" "env"

    assert_success
    assert_output "${BATS_TEST_DIRNAME}/testsData/dsn/default.local.env"
  )
}

function Profiles::getAbsoluteConfFile::RootDir { #@test
  (
    export ROOT_DIR="${BATS_TMP_DIR}"
    run Profiles::getAbsoluteConfFile "dsn2" "myConf" ".sh"

    assert_success
    assert_output "${BATS_TMP_DIR}/conf/dsn2/myConf.sh"
  )
}

function Profiles::getAbsoluteConfFile::AbsoluteFileIgnoresConfFolderAndExt { #@test
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt.ext"

  run Profiles::getAbsoluteConfFile "data" "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt.ext" "sh"
  assert_success
  assert_output "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt.ext"
}

function Profiles::getAbsoluteConfFile::AbsoluteFileIgnoresConfFolderAndExt2 { #@test
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/dsn_invalid_port.sh"

  run Profiles::getAbsoluteConfFile "${BATS_TMP_DIR}/home/.bash-tools/dsn/dsn_invalid_port.sh" "data" "env"
  assert_success
  assert_output "${BATS_TMP_DIR}/home/.bash-tools/dsn/dsn_invalid_port.sh"
}

function Profiles::getAbsoluteConfFile::FileWithoutExtension { #@test
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/noExtension"

  run Profiles::getAbsoluteConfFile "dsn" "noExtension" ""
  assert_success
  assert_output "${BATS_TMP_DIR}/home/.bash-tools/dsn/noExtension"
}

function Profiles::getAbsoluteConfFile::FileNotFound { #@test
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"

  run Profiles::getAbsoluteConfFile "dsn" "invalidFile" "env"
  assert_failure 1
  assert_output --partial "ERROR   - conf file 'invalidFile' not found"
}
