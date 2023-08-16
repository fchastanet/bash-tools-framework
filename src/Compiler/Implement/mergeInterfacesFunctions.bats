#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Implement/mergeInterfacesFunctions.sh
source "${srcDir}/Compiler/Implement/mergeInterfacesFunctions.sh"
# shellcheck source=src/Compiler/Implement/interfaceFunctions.sh
source "${srcDir}/Compiler/Implement/interfaceFunctions.sh"
# shellcheck source=src/Compiler/Implement/filter.sh
source "${srcDir}/Compiler/Implement/filter.sh"
# shellcheck source=src/Compiler/Implement/interfaces.sh
source "${srcDir}/Compiler/Implement/interfaces.sh"
# shellcheck source=src/Compiler/Implement/parse.sh
source "${srcDir}/Compiler/Implement/parse.sh"
# shellcheck source=src/Compiler/Implement/assertInterface.sh
source "${srcDir}/Compiler/Implement/assertInterface.sh"
# shellcheck source=src/Filters/removeExternalQuotes.sh
source "${srcDir}/Filters/removeExternalQuotes.sh"
# shellcheck source=src/Assert/bashFrameworkFunction.sh
source "${srcDir}/Assert/bashFrameworkFunction.sh"
# shellcheck source=src/Assert/posixFunctionName.sh
source "${srcDir}/Assert/posixFunctionName.sh"
# shellcheck source=src/Compiler/Embed/getSrcDirsFromOptions.sh
source "${srcDir}/Compiler/Embed/getSrcDirsFromOptions.sh"
# shellcheck source=src/Compiler/findFunctionInSrcDirs.sh
source "${srcDir}/Compiler/findFunctionInSrcDirs.sh"

function Compiler::Implement::mergeInterfacesFunctions::twoInterfaces { #@test
  local -a _EMBED_COMPILE_ARGUMENTS=(
    --src-dir "${BATS_TEST_DIRNAME}/testsData"
  )
  local status=0
  Compiler::Implement::mergeInterfacesFunctions \
    "${BATS_TEST_DIRNAME}/testsData/interfacesTwo.sh" >"${BATS_TEST_TMPDIR}/result" 2>&1 || status=$?

  [[ "${status}" = "0" ]] || {
    cat "${BATS_TEST_TMPDIR}/result" >&3
    return 1
  }
  run cat "${BATS_TEST_TMPDIR}/result"
  assert_output "$(cat "${BATS_TEST_DIRNAME}/testsData/mergeInterfacesFunctions.twoInterfaces.expected.txt")"
}
