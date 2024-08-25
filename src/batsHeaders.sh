#!/usr/bin/env bash

export SCRIPT_NAME="test"
FRAMEWORK_ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)
vendorDir="${FRAMEWORK_ROOT_DIR}/vendor"
srcDir="${FRAMEWORK_ROOT_DIR}/src"
export FRAMEWORK_ROOT_DIR="${FRAMEWORK_ROOT_DIR}"
export BASH_FRAMEWORK_DISPLAY_LEVEL=3
export DISPLAY_DURATION=0

# ensure that no user aliases could interfere with
# commands used in this script
unalias -a || true
shopt -u expand_aliases

# shellcheck disable=SC2034
((failures = 0)) || true

# Bash will remember & return the highest exit code in a chain of pipes.
# This way you can catch the error inside pipes, e.g. mysqldump | gzip
set -o pipefail
set -o errexit

# Command Substitution can inherit errexit option since bash v4.4
shopt -s inherit_errexit || true

# if set, and job control is not active, the shell runs the last command
# of a pipeline not executed in the background in the current shell
# environment.
shopt -s lastpipe

# a log is generated when a command fails
set -o errtrace

# use nullglob so that (file*.php) will return an empty array if no file
# matches the wildcard
shopt -s nullglob

# ensure regexp are interpreted without accentuated characters
export LC_ALL=POSIX

export TERM=xterm-256color

# avoid interactive install
export DEBIAN_FRONTEND=noninteractive
export DEBCONF_NONINTERACTIVE_SEEN=true

# store command arguments for later usage
# shellcheck disable=SC2034
declare -a BASH_FRAMEWORK_ARGV=("$@")
# shellcheck disable=SC2034
declare -a ORIGINAL_BASH_FRAMEWORK_ARGV=("$@")

# @see https://unix.stackexchange.com/a/386856
# shellcheck disable=SC2317
interruptManagement() {
  # restore SIGINT handler
  trap - INT
  # ensure that Ctrl-C is trapped by this script and not by sub process
  # report to the parent that we have indeed been interrupted
  kill -s INT "$$"
}
trap interruptManagement INT

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=/src/_standalone/Bats/assert_lines_count.sh
source "${srcDir}/_standalone/Bats/assert_lines_count.sh"
# shellcheck source=/src/Env/__all.sh
source "${srcDir}/Env/__all.sh"
# shellcheck source=src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
# shellcheck source=src/UI/theme.sh
source "${srcDir}/UI/theme.sh"
# shellcheck source=src/Assert/tty.sh
source "${srcDir}/Assert/tty.sh"

initLogs() {
  local envFile="$1"
  unset BASH_FRAMEWORK_THEME
  unset BASH_FRAMEWORK_LOG_LEVEL
  unset BASH_FRAMEWORK_DISPLAY_LEVEL
  BASH_FRAMEWORK_ENV_FILES=("${BATS_TEST_DIRNAME}/testsData/${envFile}")
  Env::requireLoad
  export DISPLAY_DURATION=0
  Log::requireLoad
}
