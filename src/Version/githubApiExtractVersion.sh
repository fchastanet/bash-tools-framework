#!/usr/bin/env bash

# extract version number from github api
# @stdin json result of github API
Version::githubApiExtractVersion() {
  jq -r ".tag_name" | Version::parse
}
