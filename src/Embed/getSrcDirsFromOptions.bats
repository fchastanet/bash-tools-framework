#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Embed/getSrcDirsFromOptions.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/Embed/getSrcDirsFromOptions.sh"

function Embed::getSrcDirsFromOptions::noArg { #@test
  run Embed::getSrcDirsFromOptions
  assert_success
  assert_output ""
}

function Embed::getSrcDirsFromOptions::1ArgLong { #@test
  run Embed::getSrcDirsFromOptions "--src-dir"
  assert_success
  assert_output ""
}

function Embed::getSrcDirsFromOptions::1ArgShort { #@test
  run Embed::getSrcDirsFromOptions "-s"
  assert_success
  assert_output ""
}

function Embed::getSrcDirsFromOptions::2ArgsLong { #@test
  run Embed::getSrcDirsFromOptions "--src-dir" "dir"
  assert_success
  assert_output "dir"
}

function Embed::getSrcDirsFromOptions::2ArgsShort { #@test
  run Embed::getSrcDirsFromOptions "-s" "dir"
  assert_success
  assert_output "dir"
}

function Embed::getSrcDirsFromOptions::severalSrcDirs { #@test
  run Embed::getSrcDirsFromOptions "-s" "dir1" "--src-dir" "dir2"
  assert_success
  assert_lines_count 2
  assert_line --index 0 "dir1"
  assert_line --index 1 "dir2"
}

function Embed::getSrcDirsFromOptions::realExample { #@test
  local -a _EMBED_COMPILE_ARGUMENTS=(
    --template-dir "${BATS_TEST_DIRNAME}/_includes"
    --src-dir "${BATS_TEST_DIRNAME}/src1"
    --bin-dir "${BATS_TEST_DIRNAME}"
    --root-dir "${BATS_TEST_DIRNAME}"
    --src-dir "${BATS_TEST_DIRNAME}/src2"
  )
  run Embed::getSrcDirsFromOptions "${_EMBED_COMPILE_ARGUMENTS[@]}"
  assert_success
  assert_lines_count 2
  assert_line --index 0 "${BATS_TEST_DIRNAME}/src1"
  assert_line --index 1 "${BATS_TEST_DIRNAME}/src2"
}

function Embed::getSrcDirsFromOptions::overrideRegexp { #@test
  getSrcDirsFromOptionsRegexp='^--my-dir|-m$' run Embed::getSrcDirsFromOptions "-m" "dir1" "--my-dir" "dir2"
  assert_success
  assert_lines_count 2
  assert_line --index 0 "dir1"
  assert_line --index 1 "dir2"
}
