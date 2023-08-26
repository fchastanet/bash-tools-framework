#!/usr/bin/env bash

rootDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)"
export FRAMEWORK_ROOT_DIR="${rootDir}"
export _COMPILE_ROOT_DIR="${rootDir}"
srcDir="$(cd "${rootDir}/src" && pwd -P)"

# shellcheck source=src/Options/__all.sh
source "${srcDir}/Options/__all.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

set -x
set -o errexit
set -o pipefail
export TMPDIR="/tmp"

Options::myCustomOption() {
  if [[ "$1" = "help" ]]; then
    echo "help"
  fi
  if [[ "$1" = "helpAlt" ]]; then
    echo "helpAlt"
  fi
}
Options::generateCommand Options::myCustomOption
