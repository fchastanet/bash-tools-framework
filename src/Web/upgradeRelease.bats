#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Web/upgradeRelease.sh
source "${srcDir}/Web/upgradeRelease.sh"

function setup() {
  export TMPDIR="${BATS_TEST_TMPDIR}"
}

function teardown() {
  unstub_all
}

function Web::upgradeRelease::success { #@test
  stub curl '-L --connect-timeout 5 -o \* --fail https://storage.googleapis.com/golang/go1.22.2.linux-amd64.tar.gz : echo "$5"'
  Web::getReleases() {
    cat "${BATS_TEST_DIRNAME}/testsData/releases.json"
  }
  Retry::default() {
    "$@"
  }
  Retry::parameterized() {
    shift 3
    "$@"
  }
  filterLatestNonBetaVersion() {
    jq -r '.[].files[].version'
  }
  getGoVersion() {
    echo "1.22.1"
  }
  Github::isReleaseVersionExist() {
    return 0
  }
  Github::defaultInstall() {
    echo "install $2 $3"
  }
  touch "${TMPDIR}/go"
  FILTER_LAST_VERSION_CALLBACK=filterLatestNonBetaVersion \
    SOFT_VERSION_CALLBACK=getGoVersion \
    run Web::upgradeRelease \
    "${TMPDIR}/go" \
    "https://go.dev/dl/?mode=json" \
    "https://storage.googleapis.com/golang/go@latestVersion@.linux-amd64.tar.gz"
  assert_success
  assert_lines_count 5
  assert_line --index 0 --partial "INFO    - Latest version found is 1.22.2"
  assert_line --index 1 --partial "INFO    - Upgrading ${TMPDIR}/go from version 1.22.1 to 1.22.2"
  assert_line --index 2 --partial "INFO    - Using url https://storage.googleapis.com/golang/go1.22.2.linux-amd64.tar.gz"
  assert_line --index 3 --regexp "^${BATS_TMP_DIR}/"
  assert_line --index 3 --regexp "web.newSoftware"
  assert_line --index 4 "install ${TMPDIR}/go 1.22.2"
}
