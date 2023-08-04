#!/usr/bin/env bash
# shellcheck disable=SC2120

Filters::toUpperCase() {
  if (($# == 1)); then
    Filters::toUpperCase <<<"$1"
  else
    tr '[:lower:]' '[:upper:]'
  fi
}
