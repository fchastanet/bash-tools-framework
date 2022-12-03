#!/usr/bin/env bash

# extract software version number
# @param $1 the command that will be called with --version parameter
Version::ask() {
  $1 --version | parseVersion
}
