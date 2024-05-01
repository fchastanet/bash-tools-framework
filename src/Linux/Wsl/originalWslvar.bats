#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/Wsl/originalWslvar.sh
source "${srcDir}/Linux/Wsl/originalWslvar.sh"

# bats file_tags=ubuntu_only

teardown() {
  unstub_all
}

function Linux::Wsl::originalWslvar::unknownVar { #@test
  stub wslvar 'dd : exit 1'
  run Linux::Wsl::originalWslvar dd
  assert_failure 1
  assert_output ""
}

function Linux::Wsl::originalWslvar::pathVar { #@test
  stub wslvar '--getsys PATH : echo "/bin:/windows"'
  run Linux::Wsl::originalWslvar --getsys PATH
  assert_success
  assert_output "/bin:/windows"
}
