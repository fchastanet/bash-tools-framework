#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Log/getLevelText.sh
source "${srcDir}/Log/getLevelText.sh"

function Log::getLevelText::debugLevel { #@test
  local levelText
  levelText=$(Log::getLevelText "${__LEVEL_DEBUG}")
  [[ "${levelText}" == "DEBUG" ]]
}

function Log::getLevelText::infoLevel { #@test
  local levelText
  levelText=$(Log::getLevelText "${__LEVEL_INFO}")
  [[ "${levelText}" == "INFO" ]]
}

function Log::getLevelText::successLevel { #@test
  local levelText
  levelText=$(Log::getLevelText "${__LEVEL_SUCCESS}")
  [[ "${levelText}" == "INFO" ]]
}

function Log::getLevelText::warningLevel { #@test
  local levelText
  levelText=$(Log::getLevelText "${__LEVEL_WARNING}")
  [[ "${levelText}" == "WARNING" ]]
}

function Log::getLevelText::errorLevel { #@test
  local levelText
  levelText=$(Log::getLevelText "${__LEVEL_ERROR}")
  [[ "${levelText}" == "ERROR" ]]
}

function Log::getLevelText::offLevel { #@test
  local levelText
  levelText=$(Log::getLevelText "${__LEVEL_OFF}")
  [[ "${levelText}" == "OFF" ]]
}

function Log::getLevelText::invalidLevel { #@test
  run Log::getLevelText "invalid"
  assert_output --partial "ERROR   - Command test - Invalid level invalid"
}
