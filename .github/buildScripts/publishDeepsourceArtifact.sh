#!/usr/bin/env bash

set -o errexit
set -o pipefail

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)
FILE="$1"
(
  cd "${BASE_DIR}"
  # Install deepsource CLI
  curl https://deepsource.io/cli | sh

  # Report coverage artifact to 'test-coverage' analyzer
  ./bin/deepsource report --analyzer shell --key shellcheck --value-file "${FILE}"
)
