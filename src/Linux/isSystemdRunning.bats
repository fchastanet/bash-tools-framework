#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/isSystemdRunning.sh
source "${srcDir}/Linux/isSystemdRunning.sh"

tearDown() {
  unstub_all
}

function Linux::isSystemdRunning::failure { #@test
  readlink() {
    if [[ "$*" != "-f /sbin/init" ]]; then
      exit 1
    fi
    echo "invalid file"
  }

  run Linux::isSystemdRunning

  assert_failure 1
  assert_output --partial "INFO    - SystemD is not running"
}

function Linux::isSystemdRunning::success { #@test
  stub systemctl 'status --no-pager : exit 0'
  readlink() {
    if [[ "$*" != "-f /sbin/init" ]]; then
      echo "invalid args"
      exit 1
    fi
    echo "/usr/lib/systemd/systemd"
  }

  run Linux::isSystemdRunning

  assert_success
  assert_output --partial "INFO    - SystemD is running"
}
