#!/usr/bin/env bash

# ensure that no user aliases could interfere with
# commands used in this script
unalias -a || true

export SCRIPT_NAME="test"
FRAMEWORK_ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)
vendorDir="${FRAMEWORK_ROOT_DIR}/vendor"
srcDir="${FRAMEWORK_ROOT_DIR}/src"
export FRAMEWORK_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"

# shellcheck disable=SC2034
((failures = 0)) || true

shopt -s expand_aliases

# Bash will remember & return the highest exit code in a chain of pipes.
# This way you can catch the error inside pipes, e.g. mysqldump | gzip
set -o pipefail
set -o errexit

# Command Substitution can inherit errexit option since bash v4.4
shopt -s inherit_errexit || true

# a log is generated when a command fails
set -o errtrace

# use nullglob so that (file*.php) will return an empty array if no file matches the wildcard
shopt -s nullglob

# ensure regexp are interpreted without accentuated characters
export LC_ALL=POSIX

export TERM=xterm-256color

#avoid interactive install
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/_standalone/Bats/assert_lines_count.sh
source "${srcDir}/_standalone/Bats/assert_lines_count.sh"
# shellcheck source=/src/Env/load.sh
source "${srcDir}/Env/load.sh"
# shellcheck source=src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
