#!/usr/bin/env bash

rootDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)"
export FRAMEWORK_ROOT_DIR="${rootDir}"
export _COMPILE_ROOT_DIR="${rootDir}"

srcDir="$(cd "${rootDir}/src" && pwd -P)"

# shellcheck source=src/Options2/__all.sh
source "${srcDir}/Options2/__all.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"


#set -x
set -o errexit
set -o pipefail
export TMPDIR="/tmp"

Object::create \
  --type group \
  --property-title "GLOBAL OPTIONS:" \
  --function-name zzzGroupGlobalOptionsFunction

Object::create \
    --type "Group" \
    --function-name "simpleObjectFunction"

Object::create \
    --type "Group" \
    --property-title "title" \
    --property-help "help" \
    --function-name "groupObjectFunction"

BASH_FRAMEWORK_DISPLAY_LEVEL=__LEVEL_DEBUG

Object::create \
  --function-name "optionFunction" \
  --type "Option" \
  --property-variableName "varName"

declare -f optionFunction
set -x
Options2::validateOptionObject optionFunction