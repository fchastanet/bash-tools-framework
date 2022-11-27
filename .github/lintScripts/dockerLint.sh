#!/usr/bin/env bash

set -o errexit
set -o pipefail

BASE_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

if (( $# == 0 )); then
  set -- -f checkstyle
fi

(
  cd "${BASE_DIR}"
  # shellcheck disable=SC2046
  hadolint "$@" $(find .docker -type f -name 'Dockerfile*')
)
status=$?
exit ${status}
