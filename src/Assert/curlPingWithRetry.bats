#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/curlPingWithRetry.sh
source "${BATS_TEST_DIRNAME}/curlPingWithRetry.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
# shellcheck source=/src/Retry/parameterized.sh
source "${srcDir}/Retry/parameterized.sh"
# shellcheck source=/src/Assert/dirExists.sh
source "${srcDir}/Assert/dirExists.sh"

teardown() {
  unstub_all
}

function Assert::testCurlPingWithRetry { #@test
  stub curl \
    "--silent -o /dev/null --fail -L --connect-timeout 5 --max-time 10 url : echo 'curl success' && exit 0"

  run Assert::curlPingWithRetry "url" "test url" "1" "0"
  assert_success
  assert_line --index 0 --partial "INFO    - Attempt 1/1: test url"
  assert_line --index 1 "curl success"
}

function Assert::testCurlPingWithRetrySuccessAtRetry2 { #@test
  stub curl \
    "--silent -o /dev/null --fail -L --connect-timeout 5 --max-time 10 url : echo 'curl failure' && exit 1" \
    "--silent -o /dev/null --fail -L --connect-timeout 5 --max-time 10 url : echo 'curl success' && exit 0"

  run Assert::curlPingWithRetry "url" "test url" "2" "0"
  assert_success
  assert_line --index 0 --partial "INFO    - Attempt 1/2: test url"
  assert_line --index 1 "curl failure"
  assert_line --index 2 --partial "WARN    - Command failed. Wait for 0 seconds"
  assert_line --index 3 --partial "INFO    - Attempt 2/2: test url"
  assert_line --index 4 "curl success"
}
