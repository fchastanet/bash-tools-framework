#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Array/wrap.sh
source "${srcDir}/Array/wrap.sh"

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
  assert_line --index 1 "t amet,:consectetur "
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
  assert_lines_count 7
  assert_line --index 0 "Usage:  Options::generateCommand --help <String|Function>"
  assert_line --index 1 "[--command-name <String|Function>]"
  assert_line --index 2 "[--version <String|Function>]"
  assert_line --index 3 "[--author <String|Function>]"
  assert_line --index 4 "[--License <String|Function>]"
  assert_line --index 5 "[--copyright <String|Function>]"
  assert_line --index 6 "[--help-template <String>]"
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
  assert_lines_count 7
  assert_line --index 0 "Usage:  Options::generateCommand --help <String|Function>"
  assert_line --index 1 "  [--command-name <String|Function>]"
  assert_line --index 2 "  [--version <String|Function>]"
  assert_line --index 3 "  [--author <String|Function>]"
  assert_line --index 4 "  [--License <String|Function>]"
  assert_line --index 5 "  [--copyright <String|Function>]"
  assert_line --index 6 "  [--help-template <String>]"
}
