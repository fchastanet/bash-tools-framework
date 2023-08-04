#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Assert/dnsHostname.sh
source "${srcDir}/Assert/dnsHostname.sh"

teardown() {
  unstub_all
}

function Assert::dnsHostname::valid { #@test
  run Assert::dnsHostname "dns.com"
  assert_success
  assert_output ""
}

function Assert::dnsHostname::invalid { #@test
  run Assert::dnsHostname "dns"
  assert_failure 1
  assert_output ""
}

function Assert::dnsHostname::invalidWithAccents { #@test
  run Assert::dnsHostname "dnsé.com" # cspell:disable-line
  assert_failure 1
  assert_output ""
}
