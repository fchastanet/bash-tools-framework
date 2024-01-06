#!/usr/bin/env bash

rootDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)"
export FRAMEWORK_ROOT_DIR="${rootDir}"
export _COMPILE_ROOT_DIR="${rootDir}"

srcDir="$(cd "${rootDir}/src" && pwd -P)"

# shellcheck source=src/Object/__all.sh
source "${srcDir}/Object/__all.sh"
# shellcheck source=src/Options2/__all.sh
source "${srcDir}/Options2/__all.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
# shellcheck source=/src/UI/theme.sh
source "${srcDir}/UI/theme.sh"
# shellcheck source=/src/Assert/tty.sh
source "${srcDir}/Assert/tty.sh"

declare -a arg=(
  --type "Arg"
  --property-variableName "var"
  --property-name "name"
  --property-help "help"
  --property-title "Global options"
  --property-mandatory 1
  --property-max 2
)
declare -a group=(
  --type "Group"
  --property-title "Global options"
  --property-help "help"
)
Options2::renderGroupHelp group
declare -a arg=(
  --type "Arg"
  --property-variableName "varName"
  --property-variableType "String"
  --array-alt "--help"
  --property-name "valid"
  --array-callback "François"
)
Options2::validateArgObject arg
UI::theme "default"
Options2::renderArgHelp arg 2>&1