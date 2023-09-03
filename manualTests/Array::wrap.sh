#!/usr/bin/env bash

rootDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)"
export FRAMEWORK_ROOT_DIR="${rootDir}"
export _COMPILE_ROOT_DIR="${rootDir}"

srcDir="$(cd "${rootDir}/src" && pwd -P)"

# shellcheck source=src/Array/wrap.sh
source "${srcDir}/Array/wrap.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
# shellcheck source=/src/UI/theme.sh
source "${srcDir}/UI/theme.sh"

#set -x
set -o errexit
set -o pipefail
export TMPDIR="/tmp"

UI::theme "default"

Array::wrap " " 80 0 "${__ERROR_COLOR}USAGE: awkLint${__RESET_COLOR}" "[--display-level <String>]" \
  "[--help|-h]" "[--log-level <String>]" "[--no-color]" "[--quiet|-q]" \
  "[--verbose|-v]" "[--version]"
