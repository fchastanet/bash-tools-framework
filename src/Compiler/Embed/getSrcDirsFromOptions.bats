#!/usr/bin/env bash
# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Compiler/Embed/getSrcDirsFromOptions.sh
source "$(cd "${BATS_TEST_DIRNAME}/../.." && pwd)/Compiler/Embed/getSrcDirsFromOptions.sh"

function Compiler::Embed::getSrcDirsFromOptions::noArg { #@test
  run Compiler::Embed::getSrcDirsFromOptions
  assert_success
  assert_output ""
}

function Compiler::Embed::getSrcDirsFromOptions::1ArgLong { #@test
  run Compiler::Embed::getSrcDirsFromOptions "--src-dir"
  assert_success
  assert_output ""
}

function Compiler::Embed::getSrcDirsFromOptions::1ArgShort { #@test
  run Compiler::Embed::getSrcDirsFromOptions "-s"
  assert_success
  assert_output ""
}

function Compiler::Embed::getSrcDirsFromOptions::2ArgsLong { #@test
  run Compiler::Embed::getSrcDirsFromOptions "--src-dir" "dir"
  assert_success
  assert_output "dir"
}

function Compiler::Embed::getSrcDirsFromOptions::2ArgsShort { #@test
  run Compiler::Embed::getSrcDirsFromOptions "-s" "dir"
  assert_success
  assert_output "dir"
}

function Compiler::Embed::getSrcDirsFromOptions::severalSrcDirs { #@test
  run Compiler::Embed::getSrcDirsFromOptions "-s" "dir1" "--src-dir" "dir2"
  assert_success
  assert_lines_count 2
  assert_line --index 0 "dir1"
  assert_line --index 1 "dir2"
}

function Compiler::Embed::getSrcDirsFromOptions::realExample { #@test
  local -a _EMBED_COMPILE_ARGUMENTS=(
    --template-dir "${BATS_TEST_DIRNAME}/_includes"
    --src-dir "${BATS_TEST_DIRNAME}/src1"
    --bin-dir "${BATS_TEST_DIRNAME}"
    --root-dir "${BATS_TEST_DIRNAME}"
    --src-dir "${BATS_TEST_DIRNAME}/src2"
  )
  run Compiler::Embed::getSrcDirsFromOptions "${_EMBED_COMPILE_ARGUMENTS[@]}"
  assert_success
  assert_lines_count 2
  assert_line --index 0 "${BATS_TEST_DIRNAME}/src1"
  assert_line --index 1 "${BATS_TEST_DIRNAME}/src2"
}

function Compiler::Embed::getSrcDirsFromOptions::overrideRegexp { #@test
  getSrcDirsFromOptionsRegexp='^--my-dir|-m$' run Compiler::Embed::getSrcDirsFromOptions "-m" "dir1" "--my-dir" "dir2"
  assert_success
  assert_lines_count 2
  assert_line --index 0 "dir1"
  assert_line --index 1 "dir2"
}
