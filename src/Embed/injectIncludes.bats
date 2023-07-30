#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Embed/injectIncludes.sh
source "${srcDir}/Embed/injectIncludes.sh"
# shellcheck source=src/Embed/filterIncludes.sh
source "${srcDir}/Embed/filterIncludes.sh"
# shellcheck source=src/Embed/parseInclude.sh
source "${srcDir}/Embed/parseInclude.sh"
# shellcheck source=src/Embed/assertAsName.sh
source "${srcDir}/Embed/assertAsName.sh"
# shellcheck source=src/Embed/assertResource.sh
source "${srcDir}/Embed/assertResource.sh"
# shellcheck source=src/Embed/include.sh
source "${srcDir}/Embed/include.sh"
# shellcheck source=src/Array/contains.sh
source "${srcDir}/Array/contains.sh"
# shellcheck source=src/Assert/validVariableName.sh
source "${srcDir}/Assert/validVariableName.sh"
# shellcheck source=src/Assert/bashFrameworkFunction.sh
source "${srcDir}/Assert/bashFrameworkFunction.sh"
# shellcheck source=src/Embed/includeFile.sh
source "${srcDir}/Embed/includeFile.sh"
# shellcheck source=src/Embed/includeDir.sh
source "${srcDir}/Embed/includeDir.sh"
# shellcheck source=src/Embed/includeFrameworkFunction.sh
source "${srcDir}/Embed/includeFrameworkFunction.sh"
# shellcheck source=src/Filters/removeExternalQuotes.sh
source "${srcDir}/Filters/removeExternalQuotes.sh"

function Embed::injectIncludes::noMatch { #@test
  local status
  local -a embeddedNames=()
  local -a embeddedResources=()
  Embed::injectIncludes embeddedNames embeddedResources <"${BATS_TEST_DIRNAME}/testsData/binaryFile" \
    >"${BATS_TEST_TMPDIR}/injectIncludes" 2>&1
  status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/injectIncludes"
  assert_output ""
}

function Embed::injectIncludes::matchButInvalidAsName { #@test
  local status="0"
  local -a embeddedNames=()
  local -a embeddedResources=()
  Embed::injectIncludes embeddedNames embeddedResources <<<"# INCLUDE 'test' as 'François'" \
    >"${BATS_TEST_TMPDIR}/injectIncludes" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/injectIncludes"
  assert_lines_count 1
  assert_output --partial "ERROR   - Invalid embed name 'François'. AS property name can only be composed by letters, numbers, underscore."
}

function Embed::injectIncludes::matchButInvalidResource { #@test
  local status="0"
  local -a embeddedNames=()
  local -a embeddedResources=()
  Embed::injectIncludes embeddedNames embeddedResources <<<"# INCLUDE 'test' as 'valid'" \
    >"${BATS_TEST_TMPDIR}/injectIncludes" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  run cat "${BATS_TEST_TMPDIR}/injectIncludes"
  assert_lines_count 1
  assert_output --partial "ERROR   - Invalid embed resource 'test'. The resource is neither a file, directory nor bash framework function"
}

function Embed::injectIncludes::matchButAsNameAlreadyIncluded { #@test
  local status="0"
  local -a embeddedNames=('valid')
  local -a embeddedResources=()
  Embed::injectIncludes embeddedNames embeddedResources <<<"# INCLUDE '${BATS_TEST_DIRNAME}/testsData/binaryFile' as 'valid'" \
    >"${BATS_TEST_TMPDIR}/injectIncludes" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/injectIncludes"
  assert_lines_count 1
  assert_output --partial "SKIPPED - Embed asName valid has already been imported previously"
}

function Embed::injectIncludes::worksWithWarningResourceAlreadyIncluded { #@test
  local status="0"
  local -a embeddedNames=()
  local -a embeddedResources=("${BATS_TEST_DIRNAME}/testsData/binaryFile")
  local _COMPILE_ROOT_DIR="${ROOT_DIR}"
  local PERSISTENT_TMPDIR="${BATS_TEST_TMPDIR}"
  Embed::injectIncludes embeddedNames embeddedResources <<<"# INCLUDE '${BATS_TEST_DIRNAME}/testsData/binaryFile' as 'valid'" \
    >"${BATS_TEST_TMPDIR}/injectIncludes" 2>"${BATS_TEST_TMPDIR}/injectIncludesError" || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/injectIncludesError"
  assert_lines_count 1
  assert_output --partial "WARN    - Embed resource ${BATS_TEST_DIRNAME}/testsData/binaryFile has already been imported previously with a different name, ensure to deduplicate"
  run diff "${BATS_TEST_TMPDIR}/injectIncludes" "${BATS_TEST_DIRNAME}/testsData/injectIncludesBinaryFile.expected.txt"
  assert_success
}

function Embed::injectIncludes::twiceSameResourceDifferentAsName { #@test
  local status="0"
  local -a embeddedNames=()
  local -a embeddedResources=()
  local _COMPILE_ROOT_DIR="${ROOT_DIR}"
  local PERSISTENT_TMPDIR="${BATS_TEST_TMPDIR}"
  dir="${BATS_TEST_DIRNAME}" envsubst <"${BATS_TEST_DIRNAME}/testsData/twiceSameResourceDifferentAsName.txt" |
    Embed::injectIncludes embeddedNames embeddedResources \
      >"${BATS_TEST_TMPDIR}/injectIncludes" 2>"${BATS_TEST_TMPDIR}/injectIncludesError" || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/injectIncludesError"
  assert_output --partial "WARN    - Embed resource ${BATS_TEST_DIRNAME}/testsData/binaryFile has already been imported previously with a different name, ensure to deduplicate"
  run diff "${BATS_TEST_TMPDIR}/injectIncludes" "${BATS_TEST_DIRNAME}/testsData/twiceSameResourceDifferentAsName.expected.txt"
  assert_success
}
