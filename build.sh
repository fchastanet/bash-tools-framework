#!/usr/bin/env bash

FRAMEWORK_ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd -P)
FRAMEWORK_SRC_DIR="$(cd "${FRAMEWORK_ROOT_DIR}/src" && pwd -P)"
FRAMEWORK_BIN_DIR="${FRAMEWORK_ROOT_DIR}/bin"

# shellcheck source=src/_includes/_header.sh
source "${FRAMEWORK_SRC_DIR}/_includes/_header.sh"
# shellcheck source=src/Env/__all.sh
source "${FRAMEWORK_SRC_DIR}/Env/__all.sh"

# parse parameters
Env::requireLoad
Env::requireRemoveVerboseArg

# srcFile     : file that needs to be compiled
# templateDir : directory from which bash-tpl templates will be searched
# binDir      : fallback bin directory in case BIN_FILE has not been provided
# rootDir     : directory used to compute src file relative path
# srcDirs     : additional directories where to find the functions
declare -a params=(
  --src-dir "${FRAMEWORK_SRC_DIR}"
  --bin-dir "${FRAMEWORK_BIN_DIR}"
  --root-dir "${FRAMEWORK_ROOT_DIR}"
)

if ((BASH_FRAMEWORK_ARGS_VERBOSE > 0)); then
  params+=("${BASH_FRAMEWORK_ARGS_VERBOSE_OPTION}")
fi

(
  set -x
  if ((${#BASH_FRAMEWORK_ARGV} == 0)); then
    find "${FRAMEWORK_SRC_DIR}/_binaries" -name "*.sh" |
      (grep -v -E '/testsData/' || true)
  else
    for file in "${BASH_FRAMEWORK_ARGV[@]}"; do
      realpath "${file}"
    done
  fi
) | xargs -t -P8 --max-args=1 --replace="{}" \
  "${FRAMEWORK_ROOT_DIR}/bin/compile" "{}" "${params[@]}"
