#!/usr/bin/env bash

# @arg $1 separator:String replace / by separator (Default value: '_')
# @stdin the name of the branch
# @stdout a string compatible with docker tag format
Docker::getTagCompatibleFromBranch() {
  local separator="${1:-_}"
  Filters::camel2snakeCase |
    sed -E \
      -e 's#^origin/##' \
      -e "s@/@${separator}@g"
}
