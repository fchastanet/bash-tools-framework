#!/usr/bin/env bash

# shellcheck disable=SC2034
SCRIPT_NAME=${0##*/}

# ensure that no user aliases could interfere with
# commands used in this script
unalias -a || true

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}":${PATH}
fi
if [[ -n "${VENDOR_BIN_DIR}" ]]; then
  export PATH="${VENDOR_BIN_DIR}":${PATH}
fi

# shellcheck source=src/_includes/_commonHeader.sh
source "$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd -P)/_commonHeader.sh"

# shellcheck source=src/_includes/_colors.sh
source "$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")" && pwd -P)/_colors.sh"
