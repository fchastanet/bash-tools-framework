.DELIMS stmt="%"
% if [[ -n "${RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR}" ]]; then
FRAMEWORK_ROOT_DIR="$(cd "${CURRENT_DIR}/<% ${RELATIVE_FRAMEWORK_DIR_TO_CURRENT_DIR} %>" && pwd -P)"
FRAMEWORK_SRC_DIR="${FRAMEWORK_ROOT_DIR}/src"
FRAMEWORK_BIN_DIR="${FRAMEWORK_ROOT_DIR}/bin"
FRAMEWORK_VENDOR_DIR="${FRAMEWORK_ROOT_DIR}/vendor"
FRAMEWORK_VENDOR_BIN_DIR="${FRAMEWORK_ROOT_DIR}/vendor/bin"
% fi
.RESET-DELIMS