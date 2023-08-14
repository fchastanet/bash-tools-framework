#!/usr/bin/env bash

# @description extract version number from github api
# @noargs
# @stdin json result of github API
# @exitcode 1 if jq or Version::parse fails
# @stdout the version parsed
# @require Linux::requireJqCommand
Version::githubApiExtractVersion() {
  jq -r ".tag_name" | Version::parse
}
