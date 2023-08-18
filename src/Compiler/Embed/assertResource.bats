#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/Embed/assertResource.sh
source "${srcDir}/Compiler/Embed/assertResource.sh"
# shellcheck source=/src/Assert/bashFrameworkFunction.sh
source "${srcDir}/Assert/bashFrameworkFunction.sh"
# shellcheck source=/src/Compiler/findFunctionInSrcDirs.sh
source "${srcDir}/Compiler/findFunctionInSrcDirs.sh"
# shellcheck source=/src/Compiler/Embed/getSrcDirsFromOptions.sh
source "${srcDir}/Compiler/Embed/getSrcDirsFromOptions.sh"

teardown() {
  rm -f "${BATS_TEST_TMPDIR}/symbolicLink" "${BATS_TEST_TMPDIR}/result" || true
}

declare -ax _EMBED_COMPILE_ARGUMENTS=(
  --src-dir "${srcDir}"
)

function Compiler::Embed::assertResource::Empty { #@test
  run Compiler::Embed::assertResource ""
  assert_failure 1
  assert_output --partial "ERROR   - Invalid embed resource ''. The resource is neither a file, directory nor bash framework function"
}

function Compiler::Embed::assertResource::InvalidFile { #@test
  ln -s "/dev/null" "${BATS_TEST_TMPDIR}/symbolicLink"
  run Compiler::Embed::assertResource "${BATS_TEST_TMPDIR}/symbolicLink"
  assert_failure 1
  assert_output --partial "ERROR   - Invalid embed resource '${BATS_TEST_TMPDIR}/symbolicLink'. The resource is neither a file, directory nor bash framework function"
}

function Compiler::Embed::assertResource::InvalidDirectory { #@test
  run Compiler::Embed::assertResource "/dev/null"
  assert_failure 1
  assert_output --partial "ERROR   - Invalid embed resource '/dev/null'. The resource is neither a file, directory nor bash framework function"
}

function Compiler::Embed::assertResource::InvalidBashFrameworkFunction { #@test
  run Compiler::Embed::assertResource "Embedded::data::François"
  assert_failure 1
  assert_output --partial "ERROR   - Invalid embed resource 'Embedded::data::François'. The resource is neither a file, directory nor bash framework function"
}

function Compiler::Embed::assertResource::File { #@test
  run Compiler::Embed::assertResource "${BATS_TEST_DIRNAME}/testsData/binaryFile"
  assert_success
  assert_output ""
}

function Compiler::Embed::assertResource::Directory { #@test
  run Compiler::Embed::assertResource "${BATS_TEST_DIRNAME}/testsData"
  assert_success
  assert_output ""
}

function Compiler::Embed::assertResource::BashFrameworkFunctionNotFound { #@test
  local -a _EMBED_COMPILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}"
  )
  local status=0
  Compiler::Embed::assertResource "Compiler::Embed::assertResource" "${BATS_TEST_DIRNAME}" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "2" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output --partial "ERROR   - Invalid embed resource 'Compiler::Embed::assertResource'. The bash framework function is not found in src dirs: ${BATS_TEST_DIRNAME}"
}

function Compiler::Embed::assertResource::BashFrameworkFunction { #@test
  local -a _EMBED_COMPILE_ARGUMENTS=(
    --src-dir "${srcDir}"
  )
  local status=0
  Compiler::Embed::assertResource "Compiler::Embed::assertResource" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output ""
}
