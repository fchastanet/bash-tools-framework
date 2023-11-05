#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Array/wrap.sh
source "${srcDir}/Array/wrap.sh"
# shellcheck source=/src/Filters/removeAnsiCodes.sh
source "${srcDir}/Filters/removeAnsiCodes.sh"

function Array::wrap::noArg { #@test
  run Array::wrap
  assert_success
  assert_output ""
}

function Array::wrap::glue { #@test
  run Array::wrap ":"
  assert_success
  assert_output ""
}

function Array::wrap::glueAndLength { #@test
  run Array::wrap ":" 12
  assert_success
  assert_output ""
}

function Array::wrap::glueLengthAndIndent { #@test
  run Array::wrap ":" 12 2
  assert_success
  assert_output ""
}

function Array::wrap::OneArrayElement::noWrap { #@test
  run Array::wrap ":" 80 0 "hello"
  assert_success
  assert_output "hello"
}

function Array::wrap::OneArrayElement::wrap { #@test
  run Array::wrap ":" 80 0 "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ac elit id massa condimentum finibus."
  assert_success
  assert_lines_count 2
  assert_line --index 0 "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur ac elit id ma"
  assert_line --index 1 "ssa condimentum finibus."
}

function Array::wrap::4ArrayElement::wrap40 { #@test
  run Array::wrap ":" 40 0 "Lorem ipsum dolor sit amet," "consectetur adipiscing elit." "Curabitur ac elit id massa" "condimentum finibus."
  assert_success
  assert_lines_count 4
  assert_line --index 0 "Lorem ipsum dolor sit amet,"
  assert_line --index 1 "consectetur adipiscing elit."
  assert_line --index 2 "Curabitur ac elit id massa"
  assert_line --index 3 "condimentum finibus."
}

function Array::wrap::4ArrayElement::wrap20 { #@test
  run Array::wrap ":" 20 0 "Lorem ipsum dolor sit amet," "consectetur adipiscing elit." "Curabitur ac elit id massa" "condimentum finibus."
  assert_success
  assert_lines_count 6
  assert_line --index 0 "Lorem ipsum dolor si"
  assert_line --index 1 "t amet,:consectetur"
  assert_line --index 2 "adipiscing elit.:Cur"
  assert_line --index 3 "abitur ac elit id ma"
  assert_line --index 4 "ssa:condimentum fini"
  assert_line --index 5 "bus."
}

function Array::wrap::realExample::noIndent { #@test
  run Array::wrap " " 80 0 \
    "Usage:  Options::generateCommand" \
    "--help <String|Function>" \
    "[--command-name <String|Function>]" \
    "[--version <String|Function>]" \
    "[--author <String|Function>]" \
    "[--License <String|Function>]" \
    "[--copyright <String|Function>]" \
    "[--help-template <String>]"
  assert_success
  assert_lines_count 4
  assert_line --index 0 "Usage:  Options::generateCommand --help <String|Function>"
  assert_line --index 1 "[--command-name <String|Function>] [--version <String|Function>]"
  assert_line --index 2 "[--author <String|Function>] [--License <String|Function>]"
  assert_line --index 3 "[--copyright <String|Function>] [--help-template <String>]"
}

function Array::wrap::realExample::indent2 { #@test
  run Array::wrap " " 80 2 \
    "Usage:  Options::generateCommand" \
    "--help <String|Function>" \
    "[--command-name <String|Function>]" \
    "[--version <String|Function>]" \
    "[--author <String|Function>]" \
    "[--License <String|Function>]" \
    "[--copyright <String|Function>]" \
    "[--help-template <String>]"
  assert_success
  assert_lines_count 4
  assert_line --index 0 "Usage:  Options::generateCommand --help <String|Function>"
  assert_line --index 1 "  [--command-name <String|Function>] [--version <String|Function>]"
  assert_line --index 2 "  [--author <String|Function>] [--License <String|Function>]"
  assert_line --index 3 "  [--copyright <String|Function>] [--help-template <String>]"
}

function Array::wrap::realExample::indent3 { #@test
  Array::wrap " " 80 0 "\e[32mDescription:\e[0m" "lint awk files


Lint all files with .awk extension in specified folder.
Filters out eventual .history folder
Result in checkstyle format." >"${BATS_TEST_TMPDIR}/result"
  diff -u "${BATS_TEST_TMPDIR}/result" <(cat "${BATS_TEST_DIRNAME}/testsData/array_wrap_indent3.expected.result") >&3
}

function Array::wrap::realExample::indent4 { #@test
  run Array::wrap " " 80 0 "USAGE: awkLint" "[--display-level <String>]" \
    "[--help|-h]" "[--log-level <String>]" "[--no-color]" "[--quiet|-q]" \
    "[--verbose|-v]" "[--version]"
  assert_lines_count 2
  assert_line --index 0 "USAGE: awkLint [--display-level <String>] [--help|-h] [--log-level <String>]"
  assert_line --index 1 "[--no-color] [--quiet|-q] [--verbose|-v] [--version]"
}

function Array::wrap::help { #@test
  run Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "test" "[--help|-h]" "[--src-dirs|-s <String>]" "[--verbose|-v]" "[--quiet|-q]"
  assert_output "$(echo -e "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR} test [--help|-h] [--src-dirs|-s <String>] [--verbose|-v] [--quiet|-q]")"
}

function Array::wrap::emptyArgShouldNotCreateNewLines { #@test
  run Array::wrap " " 80 2 "line1" "" "line2"
  assert_lines_count 2
  assert_line --index 0 "line1"
  assert_line --index 1 "  line2"
}

function Array::wrap::argWithForcedNewLines { #@test
  Array::wrap " " 80 2 "line1" $'\n' "line2" >"${BATS_TEST_TMPDIR}/result"
  diff -u "${BATS_TEST_TMPDIR}/result" <(cat "${BATS_TEST_DIRNAME}/testsData/array_wrap_emptyLinesWithForcedNewLines.expected.result") >&3
}

function Array::wrap::argFunction { #@test
  help() {
    echo "container should be the name of a profile from profile list,"
    echo "check containers list below." $'\n'
    echo "If not provided, it will load the container specified in default configuration." $'\n'
  }

  Array::wrap ' ' 76 4 "$(help)" >"${BATS_TEST_TMPDIR}/result2"
  diff -u "${BATS_TEST_TMPDIR}/result2" <(cat "${BATS_TEST_DIRNAME}/testsData/array_wrap_argFunction.expected.result") >&3
}

function Array::wrap::multilineArg { #@test
  local -a helpArray=($'\n  Common Commands:\n  run         Create and run a new container from an image\n  exec        Execute a command in a running container\n  ps          List containers\n  build       Build an image from a Dockerfile\n  pull        Download an image from a registry\n  push        Upload an image to a registry\n  images      List images\n  login       Log in to a registry\n  logout      Log out from a registry\n  search      Search Docker Hub for images\n  version     Show the Docker version information\n  info        Display system-wide information')

  Array::wrap " " 76 4 "${helpArray[@]}" >"${BATS_TEST_TMPDIR}/result3"
  diff -u "${BATS_TEST_TMPDIR}/result3" <(cat "${BATS_TEST_DIRNAME}/testsData/array_wrap_multilineArg.expected.result") >&3

  echo -e "$(Array::wrap " " 76 4 "${helpArray[@]}")" >"${BATS_TEST_TMPDIR}/result4"
  diff -u "${BATS_TEST_TMPDIR}/result4" <(cat "${BATS_TEST_DIRNAME}/testsData/array_wrap_multilineArg.expected.result") >&3
}
