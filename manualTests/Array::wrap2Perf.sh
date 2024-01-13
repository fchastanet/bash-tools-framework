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

time (
  for ((c = 1; c <= 100; c++)); do
    Array::wrap2 ' ' 76 4 $'
${__HELP_TITLE_COLOR}Common Commands:${__RESET_COLOR}
run         Create and run a new container from an image
exec        Execute a command in a running container
ps          List containers
build       Build an image from a Dockerfile
pull        Download an image from a registry
push        Upload an image to a registry\r
images      List images\r
login       Log in to a registry\r
logout      Log out from a registry
search      Search Docker Hub for images
version     Show the Docker version information
info        Display system-wide information
'
  done
)
