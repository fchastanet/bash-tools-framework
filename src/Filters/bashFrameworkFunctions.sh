#!/usr/bin/env bash

Filters::bashFrameworkFunctions() {
  grep -Eo "${PREFIX:-}([A-Za-z0-9_]+[A-Za-z0-9_-]*::)+([a-zA-Z0-9_-]+)" "$@"
}
