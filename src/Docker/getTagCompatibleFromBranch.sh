#!/usr/bin/env bash

# @param {String} separator $1
# @paramDefault {String} separator $1 '_'
# @stdin the name of the branch
# @stdout a string compatible with docker tag format
Docker::getTagCompatibleFromBranch() {
  local separator="${1:-_}"
  Filters::toLowerCase |
    sed \
      -e 's#^origin/##' \
      -e "s@/@${separator}@g"
}
