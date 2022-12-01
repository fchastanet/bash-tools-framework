#!/usr/bin/env bash

set -o errexit
set -o pipefail

BASE_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)

if (($# == 0)); then
  set -- --check-sourced -x -f checkstyle
fi

(
  cd "${BASE_DIR}"
  # shellcheck disable=SC2046
  LC_ALL=C.UTF-8 shellcheck "$@" \
    $(find . -type f \
      -not -path './LICENSE' \
      -not -path './vendor/*' \
      -not -path './.git/*' \
      -not -path './bin/hadolint' \
      -not -path './.github/*' \
      -not -path './.docker/*' \
      -not -path './.history/*' \
      -not -path './tests/tools/data/*' \
      -not -path './tests/bash-framework/data/*' \
      -not -path './tests/bash-framework/dataGetList/*' \
      -regextype posix-egrep \
      ! -regex '.*\.(env|log|sql|puml|awk|bats|md|xml|png|iml|query|json)$' ! -name '.*')
)
