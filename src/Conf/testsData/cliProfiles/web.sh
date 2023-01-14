#!/usr/bin/env bash

# shellcheck disable=SC2034
# shellcheck disable=SC2154
finalContainerArg="project-apache2"

# shellcheck disable=SC2034
# shellcheck disable=SC2154
finalUserArg="${userArg:-www-data}"

# we are using // to keep compatibility with "windows git bash"
# shellcheck disable=SC2034
# shellcheck disable=SC2154
finalCommandArg=("${commandArg:-//bin/bash}")
