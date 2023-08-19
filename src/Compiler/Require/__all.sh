#!/usr/bin/env bash

# shellcheck source=src/Compiler/Require/requires.sh
source "${FRAMEWORK_ROOT_DIR}/src/Compiler/Require/requires.sh"
# shellcheck source=src/Framework/createTempFile.sh
source "${FRAMEWORK_ROOT_DIR}/src/Framework/createTempFile.sh"
# shellcheck source=src/Compiler/Require/filter.sh
source "${FRAMEWORK_ROOT_DIR}/src/Compiler/Require/filter.sh"
# shellcheck source=src/Compiler/Require/parse.sh
source "${FRAMEWORK_ROOT_DIR}/src/Compiler/Require/parse.sh"
# shellcheck source=src/Compiler/Require/assertRequire.sh
source "${FRAMEWORK_ROOT_DIR}/src/Compiler/Require/assertRequire.sh"
# shellcheck source=src/Filters/removeExternalQuotes.sh
source "${FRAMEWORK_ROOT_DIR}/src/Filters/removeExternalQuotes.sh"
# shellcheck source=src/Assert/bashFrameworkFunction.sh
source "${FRAMEWORK_ROOT_DIR}/src/Assert/bashFrameworkFunction.sh"
# shellcheck source=/src/Compiler/findFunctionInSrcDirs.sh
source "${FRAMEWORK_ROOT_DIR}/src/Compiler/findFunctionInSrcDirs.sh"
# shellcheck source=/src/Compiler/Embed/getSrcDirsFromOptions.sh
source "${FRAMEWORK_ROOT_DIR}/src/Compiler/Embed/getSrcDirsFromOptions.sh"
