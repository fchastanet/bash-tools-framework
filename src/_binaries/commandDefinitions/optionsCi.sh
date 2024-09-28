#!/usr/bin/env bash

# shellcheck disable=SC2034
declare optionContinuousIntegrationMode=0

# shellcheck disable=SC2317 # if function is overridden
updateOptionContinuousIntegrationMode() {
  BASH_FRAMEWORK_ARGV_FILTERED+=("$1")
}
