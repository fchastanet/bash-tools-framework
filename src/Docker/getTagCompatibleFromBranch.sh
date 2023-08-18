#!/usr/bin/env bash

# @description generates a string compatible with docker tag format
# Eg: transforms origin/feature/My-beautiful-feature to feature_my_beautiful_feature
# @arg $1 separator:String replace / by separator (Default value: '_')
# @stdin the name of the branch
# @stdout a string compatible with docker tag format
# @require Docker::requireDockerCommand
Docker::getTagCompatibleFromBranch() {
  local separator="${1:-_}"
  Filters::camel2snakeCase |
    sed -E \
      -e 's#^origin/##' \
      -e "s@/@${separator}@g"
}
