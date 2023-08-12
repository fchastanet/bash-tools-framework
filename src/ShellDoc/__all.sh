#!/usr/bin/env bash

# shellcheck source=src/ShellDoc/appendDocToIndex.sh
source "${FRAMEWORK_ROOT_DIR}/src/ShellDoc/appendDocToIndex.sh"
# shellcheck source=src/ShellDoc/generateShellDoc.sh
source "${FRAMEWORK_ROOT_DIR}/src/ShellDoc/generateShellDoc.sh"
# shellcheck source=src/ShellDoc/generateShellDocsFromDir.sh
source "${FRAMEWORK_ROOT_DIR}/src/ShellDoc/generateShellDocsFromDir.sh"
# shellcheck source=src/ShellDoc/installRequirementsIfNeeded.sh
source "${FRAMEWORK_ROOT_DIR}/src/ShellDoc/installRequirementsIfNeeded.sh"
# shellcheck source=src/Git/shallowClone.sh
source "${FRAMEWORK_ROOT_DIR}/src/Git/shallowClone.sh"
