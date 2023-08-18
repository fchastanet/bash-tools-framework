#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Facade/facade.sh
source "${srcDir}/Compiler/Facade/facade.sh"

function Compiler::Facade::facadeFilterFails { #@test
  Compiler::Facade::filter() {
    return 1
  }
  local status=0

  Compiler::Facade::facade 'invalidFile' >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "3" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Compiler::Facade::noFacadeFound { #@test
  Compiler::Facade::filter() {
    return 0
  }
  local status=0

  Compiler::Facade::facade 'validFile' >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 --partial "SKIPPED - no facade found in validFile"
}

function Compiler::Facade::2FacadesFound { #@test
  Compiler::Facade::filter() {
    echo "# FACADE"
    echo "# FACADE "_includes/facade2.tpl""
    return 0
  }
  local status=0

  Compiler::Facade::facade 'validFile' >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 --partial "ERROR   - A script file can only use one FACADE directive"
}

function Compiler::Facade::1FacadeFailedToParse { #@test
  Compiler::Facade::filter() {
    echo "# FACADE invalidTemplate"
    return 0
  }
  Compiler::Facade::parse() {
    echo "parsing $1 failed"
    return 1
  }
  local status=0

  Compiler::Facade::facade 'validFile' >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "2" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 "parsing # FACADE invalidTemplate failed"
}

function Compiler::Facade::generateDefaultTemplate { #@test
  Compiler::Facade::filter() {
    echo "# FACADE"
    return 0
  }
  Compiler::Facade::parse() {
    echo "parse $1 success"
    return 0
  }
  Compiler::Facade::generateFacadeScript() {
    echo "generate $2 for $1"
  }
  local status=0

  Compiler::Facade::facade 'validFile' >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "parse # FACADE success"
  # path not complete because TEMPLATE_DIR not set
  assert_line --index 1 "generate /_includes/facadeDefault/facadeDefault.tpl for validFile"
}

function Compiler::Facade::generateCustomTemplate { #@test
  Compiler::Facade::filter() {
    echo "# FACADE custom"
    return 0
  }
  Compiler::Facade::parse() {
    local str="$1"
    local -n ref_template=$2
    echo "parse $1 success"
    ref_template="custom"
    return 0
  }
  Compiler::Facade::generateFacadeScript() {
    echo "generate $2 for $1"
  }
  local status=0
  local

  Compiler::Facade::facade 'validFile' >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 2
  assert_line --index 0 "parse # FACADE custom success"
  # path not complete because TEMPLATE_DIR not set
  assert_line --index 1 "generate custom for validFile"
}
