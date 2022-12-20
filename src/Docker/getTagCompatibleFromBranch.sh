#!/usr/bin/env bash

# @param {String} separator $1 replace / by separator
# @paramDefault {String} separator $1 '_'
# @stdin the name of the branch
# @stdout a string compatible with docker tag format
Docker::getTagCompatibleFromBranch() {
  local separator="${1:-_}"
  Filters::camel2snakeCase |
    sed \
      -e 's#^origin/##' \
      -e "s@/@${separator}@g"
}
