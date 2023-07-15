#!/usr/bin/env bash

Assert::bashFrameworkFunction() {
  local bashFrameworkFunction="$1"
  local expectedRegexp="^${PREFIX:-}([A-Za-z0-9_]+[A-Za-z0-9_-]*::)+([a-zA-Z0-9_-]+)\$"

  [[ "${bashFrameworkFunction}" =~ ${expectedRegexp} ]]
}
