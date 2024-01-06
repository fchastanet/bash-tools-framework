#!/usr/bin/env bash

# shellcheck source=src/UI/theme.sh
source "${FRAMEWORK_ROOT_DIR}/src/UI/theme.sh"
# shellcheck source=src/Options/bashTpl.sh
source "${FRAMEWORK_ROOT_DIR}/src/Options/bashTpl.sh"
  # shellcheck source=src/Options/assertAlt.sh
  source "${FRAMEWORK_ROOT_DIR}/src/Options/assertAlt.sh"
# shellcheck source=/src/Assert/posixFunctionName.sh
source "${FRAMEWORK_ROOT_DIR}/src/Assert/posixFunctionName.sh"
# shellcheck source=/src/Assert/bashFrameworkFunction.sh
source "${FRAMEWORK_ROOT_DIR}/src/Assert/bashFrameworkFunction.sh"
# shellcheck source=/src/Assert/validVariableName.sh
source "${FRAMEWORK_ROOT_DIR}/src/Assert/validVariableName.sh"
# shellcheck source=/src/Array/contains.sh
source "${FRAMEWORK_ROOT_DIR}/src/Array/contains.sh"
# shellcheck source=/src/Array/join.sh
source "${FRAMEWORK_ROOT_DIR}/src/Array/join.sh"
# shellcheck source=/src/Filters/removeAnsiCodes.sh
source "${FRAMEWORK_ROOT_DIR}/src/Filters/removeAnsiCodes.sh"
# shellcheck source=/src/Array/wrap2.sh
source "${FRAMEWORK_ROOT_DIR}/src/Array/wrap2.sh"
# shellcheck source=/src/Framework/createTempFile.sh
source "${FRAMEWORK_ROOT_DIR}/src/Framework/createTempFile.sh"
# shellcheck source=/src/Crypto/uuidV4.sh
source "${FRAMEWORK_ROOT_DIR}/src/Crypto/uuidV4.sh"
# shellcheck source=src/Options/generateFunction.sh
source "${FRAMEWORK_ROOT_DIR}/src/Options/generateFunction.sh"
# shellcheck source=src/Object/create.sh
source "${FRAMEWORK_ROOT_DIR}/src/Object/create.sh"
# shellcheck source=src/Object/getProperty.sh
source "${FRAMEWORK_ROOT_DIR}/src/Object/getProperty.sh"

# shellcheck source=src/Options2/validateCommandObject.sh
source "${FRAMEWORK_ROOT_DIR}/src/Options2/validateCommandObject.sh"

# shellcheck source=src/Options2/validateGroupObject.sh
source "${FRAMEWORK_ROOT_DIR}/src/Options2/validateGroupObject.sh"
# shellcheck source=src/Options2/renderGroupHelp.sh
source "${FRAMEWORK_ROOT_DIR}/src/Options2/renderGroupHelp.sh"

# shellcheck source=src/Options2/validateArgObject.sh
source "${FRAMEWORK_ROOT_DIR}/src/Options2/validateArgObject.sh"
# shellcheck source=src/Options2/renderArgHelp.sh
source "${FRAMEWORK_ROOT_DIR}/src/Options2/renderArgHelp.sh"

# shellcheck source=src/Options2/validateOptionObject.sh
source "${FRAMEWORK_ROOT_DIR}/src/Options2/validateOptionObject.sh"
# shellcheck source=src/Options2/renderOptionHelp.sh
source "${FRAMEWORK_ROOT_DIR}/src/Options2/renderOptionHelp.sh"
