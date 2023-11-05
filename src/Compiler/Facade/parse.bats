#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Facade/parse.sh
source "${srcDir}/Compiler/Facade/parse.sh"
# shellcheck source=src/Filters/removeExternalQuotes.sh
source "${srcDir}/Filters/removeExternalQuotes.sh"
# shellcheck source=src/Filters/trimString.sh
source "${srcDir}/Filters/trimString.sh"

assertFacadeTemplateStatus=0

setup() {
  function Compiler::Facade::assertFacadeTemplate() {
    echo "Compiler::Facade::assertFacadeTemplate called"
    return ${assertFacadeTemplateReturnStatus}
  }
  export -f Compiler::Facade::assertFacadeTemplate
}

teardown() {
  unset -f Compiler::Facade::assertFacadeTemplate
}

function Compiler::Facade::parse::noMatch { #@test
  local templateName=""
  assertFacadeTemplateReturnStatus=0
  local status=0

  Compiler::Facade::parse '# FAQ' \
    templateName >${BATS_TEST_TMPDIR}/result 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${templateName}" = '' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}

function Compiler::Facade::parse::defaultFacade { #@test
  local templateName=""
  assertFacadeTemplateReturnStatus=0
  local status=0

  dynamicTemplateDir() {
    echo "/$1"
  }
  Compiler::Facade::parse '# FACADE' \
    templateName >${BATS_TEST_TMPDIR}/result 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${templateName}" = '/_includes/facadeDefault/facadeDefault.tpl' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output "Compiler::Facade::assertFacadeTemplate called"
}

function Compiler::Facade::parse::defaultFacade2 { #@test
  local templateName=""
  assertFacadeTemplateReturnStatus=0
  local status=0
  dynamicTemplateDir() {
    echo "/$1"
  }
  Compiler::Facade::parse '# FACADE     ' \
    templateName >${BATS_TEST_TMPDIR}/result 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  [[ "${templateName}" = '/_includes/facadeDefault/facadeDefault.tpl' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 "Compiler::Facade::assertFacadeTemplate called"
}

function Compiler::Facade::parse::facadeTemplate { #@test
  local templateName=""
  assertFacadeTemplateReturnStatus=0
  local status=0

  dynamicTemplateDir() {
    echo "$1"
  }
  Compiler::Facade::parse '# FACADE    "template"' \
    templateName >${BATS_TEST_TMPDIR}/result 2>&1 || status=$?

  [[ "${status}" = "0" ]]
  [[ "${templateName}" = 'template' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 "Compiler::Facade::assertFacadeTemplate called"
}

function Compiler::Facade::parse::targetFile::withoutQuotes { #@test
  local templateName=""
  assertFacadeTemplateReturnStatus=0
  local status=0

  dynamicTemplateDir() {
    echo "$1"
  }
  Compiler::Facade::parse \
    '# FACADE _includes/facadeNewTemplate.tpl   ' \
    templateName >${BATS_TEST_TMPDIR}/result 2>&1 || status=$?
  [[ "${templateName}" = '_includes/facadeNewTemplate.tpl' ]]
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_line --index 0 "Compiler::Facade::assertFacadeTemplate called"
}

function Compiler::Facade::parse::invalidTemplateFile { #@test
  assertFacadeTemplateReturnStatus=1
  local templateName=""
  local status=0
  export BATS_TEST_DIRNAME
  dynamicTemplateDir() {
    echo "$1"
  }
  Compiler::Facade::parse $'# FACADE "invalidTemplateFile"' \
    templateName >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "${templateName}" = 'invalidTemplateFile' ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_lines_count 1
  assert_output "Compiler::Facade::assertFacadeTemplate called"
}
