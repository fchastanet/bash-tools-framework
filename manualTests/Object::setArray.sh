#!/usr/bin/env bash

rootDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)"
export FRAMEWORK_ROOT_DIR="${rootDir}"
export _COMPILE_ROOT_DIR="${rootDir}"

srcDir="$(cd "${rootDir}/src" && pwd -P)"

# shellcheck source=src/Object/__all.sh
source "${srcDir}/Object/__all.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

declare -a missingArrayTerminator=(
  --type "missingArrayTerminatorType"
  --array-list "elem1" "elem2" "elem3"
  --property-property "propertyValue"
)
Object::setArray missingArrayTerminator --array-list "newElem1" "newElem2"

declare -p missingArrayTerminator
