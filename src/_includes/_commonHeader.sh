#!/usr/bin/env bash

# shellcheck disable=SC2034
TMPDIR="$(mktemp -d -p "${TMPDIR:-/tmp}" -t bash-framework-$$-XXXXXX)"
export TMPDIR

# temp dir cleaning
cleanOnExit() {
  rm -Rf "${TMPDIR}" >/dev/null 2>&1
}
trap cleanOnExit EXIT HUP QUIT ABRT TERM

# @see https://unix.stackexchange.com/a/386856
interruptManagement() {
  # restore SIGINT handler
  trap - INT
  # ensure that Ctrl-C is trapped by this script and not by sub process
  # report to the parent that we have indeed been interrupted
  kill -s INT "$$"
}
trap interruptManagement INT

# shellcheck disable=SC2034
((failures = 0)) || true

shopt -s expand_aliases

# Bash will remember & return the highest exit code in a chain of pipes.
# This way you can catch the error inside pipes, e.g. mysqldump | gzip
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
