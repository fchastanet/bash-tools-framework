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
# shellcheck source=src/Array/wrap2.sh
source "${srcDir}/Array/wrap2.sh"
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
# Array::wrap " " 80 0 "\e[32mDescription:\e[0m" "lint awk files

# Lint all files with .awk extension in specified folder.
# Filters out eventual .history folder
# Result in checkstyle format."

# Array::wrap " " 80 2 "line1" $'\n' "line2"

# help() {
#   echo "user to connect on this container" $'\n'
#   echo "Default user"
#   echo "is loaded from profile selected as first arg or deduced from default"
#   echo "configuration"
#   echo "if first arg is not a profile"
# }

declare -a helpArray=(
  $'\n  Common Commands:\n  run         Create and run a new container from an image\n  exec        Execute a command in a running container\n  ps          List containers\n  build       Build an image from a Dockerfile\n  pull        Download an image from a registry\n  push        Upload an image to a registry\n  images      List images\n  login       Log in to a registry\n  logout      Log out from a registry\n  search      Search Docker Hub for images\n  version     Show the Docker version information\n  info        Display system-wide information'
)

echo "-------------"
for ((j = 0; j < 1; j++)); do
  Array::wrap2 " " 20 4 "${helpArray[@]}"
done
echo "-------------"

echo "@@@@@@@@@@@@@ using fold"
fold -s -w 20 - <<<"${helpArray[@]}"
time (
  for ((j = 0; j < 100; j++)); do
    fold -w 20 - <<<"${helpArray[@]}" &>/dev/null
  done
)
echo "@@@@@@@@@@@@@"

echo "############# using fmt"
fmt --width=20 --goal=20 -s -t -p '    ' - <<<"${helpArray[@]}" | pr -T --indent=4
echo "#############"
