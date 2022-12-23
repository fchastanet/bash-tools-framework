#!/usr/bin/env bash

Filters::bashFrameworkFunctions() {
  grep -Eoi '([a-z0-9_]+[a-z0-9_-]*::)+([a-z0-9_-]+)' "$@"
}
