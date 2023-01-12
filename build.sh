#!/usr/bin/env bash

ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd -P)
SRC_DIR="$(cd "${ROOT_DIR}/src" && pwd -P)"
BIN_DIR="${ROOT_DIR}/bin"
# shellcheck disable=SC2034
FRAMEWORK_DIR="${ROOT_DIR}"

# shellcheck source=src/_includes/_header.sh
source "${SRC_DIR}/_includes/_header.sh"
# shellcheck source=src/Env/load.sh
source "${SRC_DIR}/Env/load.sh"
# shellcheck source=src/Log/__all.sh
source "${SRC_DIR}/Log/__all.sh"

export REPOSITORY_URL="https://github.com/fchastanet/bash-tools-framework/tree/master"
if (($# == 0)); then
  while IFS= read -r file; do
    "${BIN_DIR}/constructBinFile" "${file}" "${SRC_DIR}" "${BIN_DIR}" "${ROOT_DIR}"
  done < <(find "${SRC_DIR}/_binaries" -name "*.sh")
else
  for file in "$@"; do
    file="$(realpath "${file}")"
    "${BIN_DIR}/constructBinFile" "${file}" "${SRC_DIR}" "${BIN_DIR}" "${ROOT_DIR}"
  done
fi
