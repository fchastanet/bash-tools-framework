#!/usr/bin/env bash

# shellcheck disable=SC2120
Filters::bashFrameworkFunctions() {
  grep -Eo "${PREFIX:-}([A-Za-z0-9_]+[A-Za-z0-9_-]*::)+([a-zA-Z0-9_-]+)" "$@" || test $? = 1
}
