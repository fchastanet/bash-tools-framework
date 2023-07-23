#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Conf/getAbsoluteFile.sh
source "${srcDir}/Conf/getAbsoluteFile.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
# shellcheck source=/src/File/concatenatePath.sh
source "${srcDir}/File/concatenatePath.sh"

setup() {
  export TMPDIR="${BATS_RUN_TMPDIR}"
  mkdir -p "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn" "${BATS_RUN_TMPDIR}/conf/dsn2"
  cp "${BATS_TEST_DIRNAME}/testsData/dsn/"* "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn"
  cp "${BATS_TEST_DIRNAME}/testsData/dsn/default.local.env" "${BATS_RUN_TMPDIR}/conf/dsn2/myConf.sh"
  export HOME="${BATS_RUN_TMPDIR}/home"
}

teardown() {
  unstub_all
}

function Conf::getAbsoluteFile::EnvFileFromHome { #@test
  run Conf::getAbsoluteFile "dsn" "default.local" "env"
  assert_success
  assert_output "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/default.local.env"
}

function Conf::getAbsoluteFile::ShFileFromHomeDefaultExtension { #@test
  touch "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"

  run Conf::getAbsoluteFile "dsn" "otherInvalidExt2"
  assert_success
  assert_output "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"
}

function Conf::getAbsoluteFile::ConfFolderDefault { #@test
  run Conf::getAbsoluteFile "dsn" "default.local" "env"
  assert_success
  assert_output "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/default.local.env"
}

function Conf::getAbsoluteFile::Relative { #@test
  mkdir -p "${BATS_RUN_TMPDIR}/home/.bash-tools/data"
  touch "${BATS_RUN_TMPDIR}/home/.bash-tools/data/dsn_valid.env"

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
    export ROOT_DIR="${BATS_RUN_TMPDIR}"
    run Conf::getAbsoluteFile "dsn2" "myConf" ".sh"

    assert_success
    assert_output "${BATS_RUN_TMPDIR}/conf/dsn2/myConf.sh"
  )
}

function Conf::getAbsoluteFile::AbsoluteFileIgnoresConfFolderAndExt { #@test
  touch "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/otherInvalidExt.ext"

  run Conf::getAbsoluteFile "data" "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/otherInvalidExt.ext" "sh"
  assert_success
  assert_output "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/otherInvalidExt.ext"
}

function Conf::getAbsoluteFile::AbsoluteFileIgnoresConfFolderAndExt2 { #@test
  touch "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/dsn_invalid_port.sh"

  run Conf::getAbsoluteFile "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/dsn_invalid_port.sh" "data" "env"
  assert_success
  assert_output "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/dsn_invalid_port.sh"
}

function Conf::getAbsoluteFile::FileWithoutExtension { #@test
  touch "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/noExtension"

  run Conf::getAbsoluteFile "dsn" "noExtension" ""
  assert_success
  assert_output "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/noExtension"
}

function Conf::getAbsoluteFile::FileNotFound { #@test
  touch "${BATS_RUN_TMPDIR}/home/.bash-tools/dsn/otherInvalidExt2.sh"

  run Conf::getAbsoluteFile "dsn" "invalidFile" "env"
  assert_failure 1
  assert_output --partial "ERROR   - conf file 'invalidFile' not found"
}
