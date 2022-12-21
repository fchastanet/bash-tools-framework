#!/usr/bin/env bash

Filters::bashFrameworkFunctions() {
  grep -Poi '([a-z0-9_]+[a-z0-9_-]*::)+([a-z0-9_-]+)' "$@"
}
