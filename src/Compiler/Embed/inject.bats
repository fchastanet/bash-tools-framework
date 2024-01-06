#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Embed/inject.sh
source "${srcDir}/Compiler/Embed/inject.sh"
# shellcheck source=src/Compiler/Embed/filter.sh
source "${srcDir}/Compiler/Embed/filter.sh"
# shellcheck source=src/Compiler/Embed/parse.sh
source "${srcDir}/Compiler/Embed/parse.sh"
# shellcheck source=src/Compiler/Embed/assertAsName.sh
source "${srcDir}/Compiler/Embed/assertAsName.sh"
# shellcheck source=src/Compiler/Embed/assertResource.sh
source "${srcDir}/Compiler/Embed/assertResource.sh"
# shellcheck source=src/Compiler/Embed/embed.sh
source "${srcDir}/Compiler/Embed/embed.sh"
# shellcheck source=src/Array/contains.sh
source "${srcDir}/Array/contains.sh"
# shellcheck source=src/Assert/validVariableName.sh
source "${srcDir}/Assert/validVariableName.sh"
# shellcheck source=src/Assert/bashFrameworkFunction.sh
source "${srcDir}/Assert/bashFrameworkFunction.sh"
# shellcheck source=src/Compiler/Embed/embedFile.sh
source "${srcDir}/Compiler/Embed/embedFile.sh"
# shellcheck source=src/Compiler/Embed/embedDir.sh
source "${srcDir}/Compiler/Embed/embedDir.sh"
# shellcheck source=src/Compiler/Embed/embedFrameworkFunction.sh
source "${srcDir}/Compiler/Embed/embedFrameworkFunction.sh"
# shellcheck source=src/Filters/removeExternalQuotes.sh
source "${srcDir}/Filters/removeExternalQuotes.sh"

function Compiler::Embed::inject::noMatch { #@test
  local status
  local -a embeddedNames=()
  local -a embeddedResources=()
  Compiler::Embed::inject embeddedNames embeddedResources <"${BATS_TEST_DIRNAME}/testsData/binaryFile" \
    >"${BATS_TEST_TMPDIR}/inject" 2>&1
  status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/inject"
  assert_output ""
}

function Compiler::Embed::inject::matchButInvalidAsName { #@test
  local status="0"
  local -a embeddedNames=()
  local -a embeddedResources=()
  Compiler::Embed::inject embeddedNames embeddedResources <<<"# EMBED 'test' as 'François'" \
    >"${BATS_TEST_TMPDIR}/inject" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/inject"
  assert_lines_count 1
  assert_output --partial "ERROR   - Invalid embed name 'François'. AS property name can only be composed by letters, numbers, underscore."
}

function Compiler::Embed::inject::matchButInvalidResource { #@test
  local status="0"
  local -a embeddedNames=()
  local -a embeddedResources=()
  Compiler::Embed::inject embeddedNames embeddedResources <<<"# EMBED 'test' as 'valid'" \
    >"${BATS_TEST_TMPDIR}/inject" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/inject"
  assert_lines_count 1
  assert_output --partial "ERROR   - Invalid embed resource 'test'. The resource is neither a file, directory nor bash framework function"
}

function Compiler::Embed::inject::matchButAsNameAlreadyIncluded { #@test
  local status="0"
  local -a embeddedNames=('valid')
  local -a embeddedResources=()
  Compiler::Embed::inject embeddedNames embeddedResources <<<"# EMBED '${BATS_TEST_DIRNAME}/testsData/binaryFile' as 'valid'" \
    >"${BATS_TEST_TMPDIR}/inject" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/inject"
  assert_lines_count 1
  assert_output --partial "SKIPPED - Embed asName valid has already been imported previously"
}

function Compiler::Embed::inject::worksWithWarningResourceAlreadyIncluded { #@test
  local status="0"
  local -a embeddedNames=()
  local -a embeddedResources=("${BATS_TEST_DIRNAME}/testsData/binaryFile")
  local _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
  local PERSISTENT_TMPDIR="${BATS_TEST_TMPDIR}"
  Compiler::Embed::inject embeddedNames embeddedResources <<<"# EMBED '${BATS_TEST_DIRNAME}/testsData/binaryFile' as 'valid'" \
    >"${BATS_TEST_TMPDIR}/inject" 2>"${BATS_TEST_TMPDIR}/injectError" || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/injectError"
  assert_lines_count 1
  assert_output --partial "WARN    - Embed resource ${BATS_TEST_DIRNAME}/testsData/binaryFile has already been imported previously with a different name, ensure to deduplicate"
  run diff "${BATS_TEST_TMPDIR}/inject" "${BATS_TEST_DIRNAME}/testsData/injectBinaryFile.expected.txt"
  assert_success
}

function Compiler::Embed::inject::twiceSameResourceDifferentAsName { #@test
  local status="0"
  local -a embeddedNames=()
  local -a embeddedResources=()
  local _COMPILE_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
  local PERSISTENT_TMPDIR="${BATS_TEST_TMPDIR}"
  dir="${BATS_TEST_DIRNAME}" envsubst <"${BATS_TEST_DIRNAME}/testsData/twiceSameResourceDifferentAsName.txt" |
    (Compiler::Embed::inject embeddedNames embeddedResources || status=$?) \
      >"${BATS_TEST_TMPDIR}/inject" 2>"${BATS_TEST_TMPDIR}/injectError"

  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/injectError"
  assert_output --partial "WARN    - Embed resource ${BATS_TEST_DIRNAME}/testsData/binaryFile has already been imported previously with a different name, ensure to deduplicate"
  run diff "${BATS_TEST_TMPDIR}/inject" "${BATS_TEST_DIRNAME}/testsData/twiceSameResourceDifferentAsName.expected.txt" >&3
  assert_success
}
