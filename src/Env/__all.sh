#!/usr/bin/env bash

# shellcheck source=src/Env/createDefaultEnvFile.sh
source "${FRAMEWORK_ROOT_DIR}/src/Env/createDefaultEnvFile.sh"
# shellcheck source=src/Env/getOrderedConfFiles.sh
source "${FRAMEWORK_ROOT_DIR}/src/Env/getOrderedConfFiles.sh"
# shellcheck source=src/Env/mergeConfFiles.sh
source "${FRAMEWORK_ROOT_DIR}/src/Env/mergeConfFiles.sh"
# shellcheck source=src/Env/parseEnvFileArg.sh
source "${FRAMEWORK_ROOT_DIR}/src/Env/parseEnvFileArg.sh"
# shellcheck source=src/Env/parseVerboseArg.sh
source "${FRAMEWORK_ROOT_DIR}/src/Env/parseVerboseArg.sh"
# shellcheck source=src/Env/pathAppend.sh
source "${FRAMEWORK_ROOT_DIR}/src/Env/pathAppend.sh"
# shellcheck source=src/Env/pathPrepend.sh
source "${FRAMEWORK_ROOT_DIR}/src/Env/pathPrepend.sh"
# shellcheck source=src/Env/requireLoad.sh
source "${FRAMEWORK_ROOT_DIR}/src/Env/requireLoad.sh"
# shellcheck source=src/Framework/createTempFile.sh
source "${FRAMEWORK_ROOT_DIR}/src/Framework/createTempFile.sh"
# shellcheck source=src/Filters/commentLines.sh
source "${FRAMEWORK_ROOT_DIR}/src/Filters/commentLines.sh"
