#!/usr/bin/env bash
# BUILD_BIN_FILE=${ROOT_DIR}/build/publishDeepsourceArtifact.sh

.INCLUDE lib/_header.tpl

# FUNCTIONS

FILE="$1"
(
  cd "${ROOT_DIR}" || exit 1
  # Install deepsource CLI
  curl https://deepsource.io/cli | sh

  # Report coverage artifact to 'test-coverage' analyzer
  ./bin/deepsource report --analyzer shell --key shellcheck --value-file "${FILE}"
)
