#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/Apt/isPackageInstalled.sh
source "${srcDir}/Linux/Apt/isPackageInstalled.sh"

teardown() {
  unstub_all
}

function Linux::Apt::isPackageInstalled::yes { #@test
  stub dpkg "-l dos2unix : cat '${BATS_TEST_DIRNAME}/testsData/isPackageInstalledYes.txt'"
  run Linux::Apt::isPackageInstalled "dos2unix"

  assert_success
  assert_output ""
}

function Linux::Apt::isPackageInstalled::no { #@test
  stub dpkg "-l groovy : cat '${BATS_TEST_DIRNAME}/testsData/isPackageInstalledNo.txt'"
  run Linux::Apt::isPackageInstalled "groovy"

  assert_failure 1
  assert_output ""
}

function Linux::Apt::isPackageInstalled::unknown { #@test
  stub dpkg "-l unknown : exit 1"
  run Linux::Apt::isPackageInstalled "unknown"

  assert_failure 1
  assert_output ""
}
