#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"
srcDir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/Assert/curlWithRetry.sh
source "${BATS_TEST_DIRNAME}/curlWithRetry.sh"
# shellcheck source=/src/Log/displayInfo.sh
source "${srcDir}/Log/displayInfo.sh"
# shellcheck source=/src/Log/displayError.sh
source "${srcDir}/Log/displayError.sh"
# shellcheck source=/src/Log/displaySuccess.sh
source "${srcDir}/Log/displaySuccess.sh"
# shellcheck source=/src/Log/displayWarning.sh
source "${srcDir}/Log/displayWarning.sh"
# shellcheck source=/src/Log/logInfo.sh
source "${srcDir}/Log/logInfo.sh"
# shellcheck source=/src/Log/logError.sh
source "${srcDir}/Log/logError.sh"
# shellcheck source=/src/Log/logSuccess.sh
source "${srcDir}/Log/logSuccess.sh"
# shellcheck source=/src/Log/logWarning.sh
source "${srcDir}/Log/logWarning.sh"
# shellcheck source=/src/Log/logMessage.sh
source "${srcDir}/Log/logMessage.sh"
# shellcheck source=/src/Retry/parameterized.sh
source "${srcDir}/Retry/parameterized.sh"
# shellcheck source=/src/Assert/dirExists.sh
source "${srcDir}/Assert/dirExists.sh"

teardown() {
  unstub_all
}

function Assert::testCurlWithRetry { #@test
  stub curl \
    "--silent -o /dev/null --fail -L --connect-timeout 5 --max-time 10 url : echo 'curl success' && exit 0"

  run Assert::curlWithRetry "url" "test url" "1" "0"
  assert_success
  assert_line --index 0 "INFO    - Attempt 1/1: test url"
  assert_line --index 1 "curl success"
}

function Assert::testCurlSuccessAtRetry2 { #@test
  stub curl \
    "--silent -o /dev/null --fail -L --connect-timeout 5 --max-time 10 url : echo 'curl failure' && exit 1" \
    "--silent -o /dev/null --fail -L --connect-timeout 5 --max-time 10 url : echo 'curl success' && exit 0"

  run Assert::curlWithRetry "url" "test url" "2" "0"
  assert_success
  assert_line --index 0 "INFO    - Attempt 1/2: test url"
  assert_line --index 1 "curl failure"
  assert_line --index 2 "WARN    - Command failed. Wait for 0 seconds"
  assert_line --index 3 "INFO    - Attempt 2/2: test url"
  assert_line --index 4 "curl success"
}
