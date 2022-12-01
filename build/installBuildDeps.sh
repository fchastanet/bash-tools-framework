#!/usr/bin/env bash

#####################################
# GENERATED FILE FROM src/build/installBuildDeps.sh
# DO NOT EDIT IT
#####################################

ROOT_DIR="/home/wsl/projects/bash-tools2"
# shellcheck disable=SC2034
LIB_DIR="${ROOT_DIR}/lib"
# shellcheck disable=SC2034

# shellcheck disable=SC2034
((failures = 0)) || true

shopt -s expand_aliases
set -o pipefail
set -o errexit
# a log is generated when a command fails
set -o errtrace
# use nullglob so that (file*.php) will return an empty array if no file matches the wildcard
shopt -s nullglob
export TERM=xterm-256color

#avoid interactive install
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# FUNCTIONS

# check colors applicable https://misc.flogisoft.com/bash/tip_colors_and_formatting
export readonly __ERROR_COLOR='\e[31m'   # Red
export readonly __INFO_COLOR='\e[44m'    # white on lightBlue
export readonly __SUCCESS_COLOR='\e[32m' # Green
export readonly __WARNING_COLOR='\e[33m' # Yellow
export readonly __SKIPPED_COLOR='\e[93m' # Light Yellow
# shellcheck disable=SC2034
export readonly __TEST_COLOR='\e[100m' # Light magenta
# shellcheck disable=SC2034
export readonly __TEST_ERROR_COLOR='\e[41m' # white on red
# shellcheck disable=SC2034
export readonly __SKIPPED_COLOR='\e[33m' # Yellow
export readonly __DEBUG_COLOR='\e[37m'   # Grey
# Internal: reset color
export readonly __RESET_COLOR='\e[0m' # Reset Color
# shellcheck disable=SC2155,SC2034
export readonly __HELP_TITLE="$(echo -e "\e[1;37m")"
# shellcheck disable=SC2155,SC2034
export readonly __HELP_NORMAL="$(echo -e "\033[0m")"

# Display message using error color (red)
# @param {String} $1 message
Log::displayError() {
  echo -e "${__ERROR_COLOR}ERROR   - ${1}\e[0m"
}

# Display message using info color (bg light blue/fg white)
# @param {String} $1 message
Log::displayInfo() {
  echo -e "${__INFO_COLOR}INFO    - ${1}${__RESET_COLOR}"
}

# Display message using warning color (yellow)
# @param {String} $1 message
Log::displayWarning() {
  echo -e "${__WARNING_COLOR}WARN    - ${1}\e[0m"
}

# Public: shallow clone a repository at specific commit sha, tag or branch
# or update repo if already exists
#
# **Arguments**:
# * $1 repository
# * $2 Install dir
# * $3 revision commit sha, tag or branch
# * $4 put 1 to force directory deletion if directory exists and it's not a git repository (default: 0)
#     USE THIS OPTION WITH CAUTION !!! as the directory will be deleted without any prompt
#
# **Return**:
# * code !=0 if git failure or directory not writable
# * code=1 if destination dir already exists and force option is not 1
Git::shallowClone() {
  REPO="$1"
  INSTALL_DIR="$2"
  REVISION="$3"
  FORCE_DELETION="${4:-0}"

  if [[ -d "${INSTALL_DIR}/.git" ]]; then
    Log::displayInfo "Repository ${INSTALL_DIR} already installed"
  else
    if [[ -f "${INSTALL_DIR}" || -d "${INSTALL_DIR}" ]]; then
      if [[ "${FORCE_DELETION}" = "1" ]]; then
        Log::displayWarning "Removing ${INSTALL_DIR} ..."
        rm -Rf "${INSTALL_DIR}" || exit 1
      else
        Log::displayError "Destination ${INSTALL_DIR} already exists, use force option to automatically delete the destination"
        return 1
      fi
    fi
    (
      Log::displayInfo "Installing ${INSTALL_DIR} ..."
      mkdir -p "${INSTALL_DIR}"
      cd "${INSTALL_DIR}" || exit 1
      git init
      git remote add origin "${REPO}"
    )
  fi
  (
    cd "${INSTALL_DIR}" || exit 1
    git -c advice.detachedHead=false fetch --depth 1 origin "${REVISION}"
    git reset --hard FETCH_HEAD
  )
}

Git::shallowClone \
  "https://github.com/fchastanet/tomdoc.sh.git" \
  "${ROOT_DIR}/vendor/fchastanet.tomdoc.sh" \
  "master" \
  "1"

Git::shallowClone \
  "https://github.com/bats-core/bats-core.git" \
  "${ROOT_DIR}/vendor/bats" \
  "v1.5.0" \
  "1"

# last revision 2019
Git::shallowClone \
  "https://github.com/bats-core/bats-support.git" \
  "${ROOT_DIR}/vendor/bats-support" \
  "master" \
  "1"

Git::shallowClone \
  "https://github.com/bats-core/bats-assert.git" \
  "${ROOT_DIR}/vendor/bats-assert" \
  "34551b1d7f8c7b677c1a66fc0ac140d6223409e5" \
  "1"

Git::shallowClone \
  "https://github.com/Flamefire/bats-mock.git" \
  "${ROOT_DIR}/vendor/bats-mock-Flamefire" \
  "1838e83473b14c79014d56f08f4c9e75d885d6b2" \
  "1"
