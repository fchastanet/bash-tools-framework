#!/usr/bin/env bash
# shellcheck disable=SC2154
# shellcheck disable=SC2034

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"
# shellcheck source=src/Linux/Wsl/getKeyFromWslpathOptions.sh
source "${srcDir}/Linux/Wsl/getKeyFromWslpathOptions.sh"

function Linux::Wsl::getKeyFromWslpathOptions::noArg { #@test
  run Linux::Wsl::getKeyFromWslpathOptions
  assert_success
  assert_output "wslpath_"
}

function Linux::Wsl::getKeyFromWslpathOptions::simplePath { #@test
  run Linux::Wsl::getKeyFromWslpathOptions /simplePath
  assert_success
  assert_output "wslpath__simplePath"
}

function Linux::Wsl::getKeyFromWslpathOptions::pathWithOptions { #@test
  run Linux::Wsl::getKeyFromWslpathOptions /simplePath -a -u -w -m
  assert_success
  assert_output "wslpath-a-u-w-m__simplePath"
}

function Linux::Wsl::getKeyFromWslpathOptions::pathWithUnknownShortOption { #@test
  run Linux::Wsl::getKeyFromWslpathOptions /simplePath -z
  assert_failure 1
  assert_output --partial "ERROR   - invalid options specified"
}

function Linux::Wsl::getKeyFromWslpathOptions::pathWithUnknownLongOption { #@test
  run Linux::Wsl::getKeyFromWslpathOptions /simplePath --help
  assert_failure 1
  assert_output --partial "ERROR   - invalid options specified"
}
