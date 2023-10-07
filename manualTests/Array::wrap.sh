#!/usr/bin/env bash

rootDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)"
export FRAMEWORK_ROOT_DIR="${rootDir}"
export _COMPILE_ROOT_DIR="${rootDir}"

srcDir="$(cd "${rootDir}/src" && pwd -P)"

# shellcheck source=src/Assert/tty.sh
source "${srcDir}/Assert/tty.sh"
# shellcheck source=src/Filters/removeAnsiCodes.sh
source "${srcDir}/Filters/removeAnsiCodes.sh"
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
#set -x
#echo -n "'"
#Array::wrap " " 80 2 "${__HELP_TITLE_COLOR}USAGE:${__RESET_COLOR}" "test" "[--help|-h]" "[--src-dirs|-s <String>]" "[--verbose|-v]" "[--quiet|-q]"
#echo "'"
#set -x
Array::wrap " " 80 0 "\e[32mDescription:\e[0m" "lint awk files

Lint all files with .awk extension in specified folder.
Filters out eventual .history folder
Result in checkstyle format."
