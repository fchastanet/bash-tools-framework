#!/usr/bin/env bash

#####################################
# GENERATED FILE FROM <% $SRC_FILE_PATH %>
# DO NOT EDIT IT
#####################################

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
