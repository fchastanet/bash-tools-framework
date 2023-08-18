#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Compiler/Facade/generateMainFunctionName.sh
source "${srcDir}/Compiler/Facade/generateMainFunctionName.sh"

function Compiler::Facade::generateMainFunctionName::uuidV4Failure { #@test
  local status=0
  Crypto::uuidV4() {
    return 1
  }
  Compiler::Facade::generateMainFunctionName >"${BATS_RUN_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "1" ]]
  [[ "$(cat "${BATS_RUN_TMPDIR}/result")" = "" ]]
}

function Compiler::Facade::generateMainFunctionName::success { #@test
  local status=0
  Crypto::uuidV4() {
    echo "3a8b2202-d904-4cb0-bdbc-a296c938fedc"
  }
  Compiler::Facade::generateMainFunctionName >"${BATS_RUN_TMPDIR}/result" 2>&1 || status=$?
  [[ "${status}" = "0" ]]
  # cspell:disable
  [[ "$(cat "${BATS_RUN_TMPDIR}/result")" = "facade_main_3a8b2202d9044cb0bdbca296c938fedc" ]]
  # cspell:enable
}
