#!/usr/bin/env bash

# shellcheck source=src/Env/createDefaultEnvFile.sh
source "${FRAMEWORK_ROOT_DIR}/src/Env/createDefaultEnvFile.sh"
# shellcheck source=src/Conf/loadNearestFile.sh
source "${FRAMEWORK_ROOT_DIR}/src/Conf/loadNearestFile.sh"
# shellcheck source=src/File/upFind.sh
source "${FRAMEWORK_ROOT_DIR}/src/File/upFind.sh"
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
# shellcheck source=src/Array/remove.sh
source "${FRAMEWORK_ROOT_DIR}/src/Array/remove.sh"
