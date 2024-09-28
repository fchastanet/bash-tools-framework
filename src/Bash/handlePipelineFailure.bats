#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Bash/handlePipelineFailure.sh
source "${srcDir}/Bash/handlePipelineFailure.sh"

function Bash::handlePipelineFailure::withHead { #@test
  local resultingStatus=0
  local -a originalPipeStatus=()
  yes | head -n 1 || Bash::handlePipelineFailure resultingStatus originalPipeStatus
  [[ "${resultingStatus}" = "0" ]]
  [[ "${originalPipeStatus[*]}" = "141 0" ]]
}

function Bash::handlePipelineFailure::withHeadWithoutStatusArg { #@test
  local status=0
  yes | head -n 1 || Bash::handlePipelineFailure || status="$?"
  [[ "${status}" = "0" ]]
}

function Bash::handlePipelineFailure::unknownCommand { #@test
  local resultingStatus=0
  local -a originalPipeStatus=()
  unknownCommand | head -n 1 || Bash::handlePipelineFailure resultingStatus originalPipeStatus || true
  [[ "${resultingStatus}" = "127" ]]
  [[ "${originalPipeStatus[*]}" = "127 0" ]]
}

function Bash::handlePipelineFailure::unknownCommandWithoutStatusArg { #@test
  local status=0
  unknownCommand | head -n 1 || Bash::handlePipelineFailure || status="$?"
  [[ "${status}" = "127" ]]
}

function Bash::handlePipelineFailure::shouldFail { #@test
  local resultingStatus=0
  local -a originalPipeStatus=()
  echo "test" | grep -q "hello" || Bash::handlePipelineFailure resultingStatus originalPipeStatus || true
  [[ "${resultingStatus}" = "1" ]]
  [[ "${originalPipeStatus[*]}" = "0 1" ]]
}

function Bash::handlePipelineFailure::shouldFailWithoutStatusArg { #@test
  local status=0
  echo "test" | grep -q "hello" || Bash::handlePipelineFailure || status="$?"
  [[ "${status}" = "1" ]]
}

function Bash::handlePipelineFailure::shouldWork { #@test
  local resultingStatus=0
  local -a originalPipeStatus=()
  "${FRAMEWORK_ROOT_DIR}/bin/findShebangFiles" --help | grep -q DESCRIPTION || Bash::handlePipelineFailure resultingStatus originalPipeStatus || true
  [[ "${resultingStatus}" = "0" ]]
  echo "${originalPipeStatus[*]}" >&3
  [[ "${originalPipeStatus[*]}" = "141 0" ]]
}

function Bash::handlePipelineFailure::shouldWorkWithoutStatusArg { #@test
  local status=0
  "${FRAMEWORK_ROOT_DIR}/bin/findShebangFiles" --help | grep -q DESCRIPTION || Bash::handlePipelineFailure || status="$?"
  [[ "${status}" = "0" ]]
}

function Bash::handlePipelineFailure::shouldWorkWith2Pipes { #@test
  local resultingStatus=0
  local -a originalPipeStatus=()
  "${FRAMEWORK_ROOT_DIR}/bin/findShebangFiles" --help | grep -q DESCRIPTION | cat || Bash::handlePipelineFailure resultingStatus originalPipeStatus || true
  [[ "${resultingStatus}" = "0" ]]
  [[ "${originalPipeStatus[*]}" = "141 0 0" ]]
}

function Bash::handlePipelineFailure::shouldWorkWith2PipesBis { #@test
  local resultingStatus=0
  local -a originalPipeStatus=()
  echo "world" | "${FRAMEWORK_ROOT_DIR}/bin/findShebangFiles" --help | grep -q DESCRIPTION || Bash::handlePipelineFailure resultingStatus originalPipeStatus || true
  [[ "${resultingStatus}" = "0" ]]
  [[ "${originalPipeStatus[*]}" = "0 141 0" ]]
}

function Bash::handlePipelineFailure::shouldFailWith2Pipes { #@test
  local resultingStatus=0
  local -a originalPipeStatus=()
  echo "test" | grep t | grep -q "hello" || Bash::handlePipelineFailure resultingStatus originalPipeStatus || true
  [[ "${resultingStatus}" = "1" ]]
  [[ "${originalPipeStatus[*]}" = "0 0 1" ]]
}

function Bash::handlePipelineFailure::shouldFailWith2PipesBis { #@test
  local resultingStatus=0
  local -a originalPipeStatus=()
  echo "test" | grep -q "hello" | grep t || Bash::handlePipelineFailure resultingStatus originalPipeStatus || true
  [[ "${resultingStatus}" = "1" ]]
  [[ "${originalPipeStatus[*]}" = "0 1 1" ]]
}
