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

# shellcheck source=/src/Conf/getAbsoluteFile.sh
source "${srcDir}/Conf/getAbsoluteFile.sh"
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

function Conf::getAbsoluteFile::EnvFileFromHome { #@test
  run Conf::getAbsoluteFile "dsn" "default.local" "env"
  assert_success
  assert_output "${BATS_TMP_DIR}/home/.bash-tools/dsn/default.local.env"
}

function Conf::getAbsoluteFile::ShFileFromHomeDefaultExtension { #@test
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"

  run Conf::getAbsoluteFile "dsn" "otherInvalidExt2"
  assert_success
  assert_output "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"
}

function Conf::getAbsoluteFile::ConfFolderDefault { #@test
  run Conf::getAbsoluteFile "dsn" "default.local" "env"
  assert_success
  assert_output "${BATS_TMP_DIR}/home/.bash-tools/dsn/default.local.env"
}

function Conf::getAbsoluteFile::Relative { #@test
  mkdir -p "${BATS_TMP_DIR}/home/.bash-tools/data"
  touch "${BATS_TMP_DIR}/home/.bash-tools/data/dsn_valid.env"

  run Conf::getAbsoluteFile "../src/Conf/testsData/dsn" "default.local" "env"

  assert_success
  assert_output "${BATS_TEST_DIRNAME}/testsData/dsn/default.local.env"
}

function Conf::getAbsoluteFile::CurrentDir { #@test
  (
    cd "${BATS_TEST_DIRNAME}"
    export CURRENT_DIR="${BATS_TEST_DIRNAME}"
    run Conf::getAbsoluteFile "testsData/dsn" "default.local" "env"

    assert_success
    assert_output "${BATS_TEST_DIRNAME}/testsData/dsn/default.local.env"
  )
}

function Conf::getAbsoluteFile::RootDir { #@test
  (
    export ROOT_DIR="${BATS_TMP_DIR}"
    run Conf::getAbsoluteFile "dsn2" "myConf" ".sh"

    assert_success
    assert_output "${BATS_TMP_DIR}/conf/dsn2/myConf.sh"
  )
}

function Conf::getAbsoluteFile::AbsoluteFileIgnoresConfFolderAndExt { #@test
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt.ext"

  run Conf::getAbsoluteFile "data" "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt.ext" "sh"
  assert_success
  assert_output "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt.ext"
}

function Conf::getAbsoluteFile::AbsoluteFileIgnoresConfFolderAndExt2 { #@test
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/dsn_invalid_port.sh"

  run Conf::getAbsoluteFile "${BATS_TMP_DIR}/home/.bash-tools/dsn/dsn_invalid_port.sh" "data" "env"
  assert_success
  assert_output "${BATS_TMP_DIR}/home/.bash-tools/dsn/dsn_invalid_port.sh"
}

function Conf::getAbsoluteFile::FileWithoutExtension { #@test
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/noExtension"

  run Conf::getAbsoluteFile "dsn" "noExtension" ""
  assert_success
  assert_output "${BATS_TMP_DIR}/home/.bash-tools/dsn/noExtension"
}

function Conf::getAbsoluteFile::FileNotFound { #@test
  touch "${BATS_TMP_DIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"

  run Conf::getAbsoluteFile "dsn" "invalidFile" "env"
  assert_failure 1
  assert_output --partial "ERROR   - conf file 'invalidFile' not found"
}
