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

export REPOSITORY_URL="https://github.com/fchastanet/bash-tools-framework"
# srcFile     : file that needs to be compiled
# templateDir : directory from which bash-tpl templates will be searched
# binDir      : fallback bin directory in case BIN_FILE has not been provided
# rootDir     : directory used to compute src file relative path
# srcDirs     : additional directories where to find the functions
declare -a params=("${SRC_DIR}" "${BIN_DIR}" "${ROOT_DIR}")
if (($# == 0)); then
  find "${SRC_DIR}/_binaries" -name "*.sh" -print |
    (grep -v -E '/testsData/' || true) |
    xargs -n1 -P8 -I{} \
      "${FRAMEWORK_DIR}/bin/constructBinFile" "{}" "${params[@]}"
else
  for file in "$@"; do
    file="$(realpath "${file}")"
    "${FRAMEWORK_DIR}/bin/constructBinFile" "${file}" "${params[@]}"
  done
fi
