#!/usr/bin/env bash

# ensure that no user aliases could interfere with
# commands used in this script
unalias -a || true

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

# @see https://unix.stackexchange.com/a/386856
interruptManagement() {
  # restore SIGINT handler
  trap - INT
  # ensure that Ctrl-C is trapped by this script and not by sub process
  # report to the parent that we have indeed been interrupted
  kill -s INT "$$"
}
trap interruptManagement INT
