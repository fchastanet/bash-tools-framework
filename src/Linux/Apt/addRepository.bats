#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/Apt/addRepository.sh
source "${srcDir}/Linux/Apt/addRepository.sh"

teardown() {
  unset -f Retry::default || true
  unstub_all
}

function Linux::Apt::addRepository::simple { #@test
  ((call = 0)) || true
  Linux::Apt::repositoryExists() {
    return 1
  }
  Retry::default() {
    ((++call))
    if ((call == 1)); then
      if [[ "$@" =~ 'add-apt-repository -y --update pkg1' ]]; then
        echo -n "success${call}"
      else
        echo -n "failure${call}"
      fi
    else
      echo -n "failure${call}"
    fi
  }

  run Linux::Apt::addRepository "pkg1"

  assert_success
  assert_line --index 0 --partial "INFO    - Apt add repository pkg1"
  assert_line --index 1 "success1"
}

function Linux::Apt::addRepository::alreadyExists { #@test
  ((call = 0)) || true
  Linux::Apt::repositoryExists() {
    return 0
  }

  run Linux::Apt::addRepository "pkg1"

  assert_success
  assert_output --partial "INFO    - Repository pkg1 is already installed"
}
