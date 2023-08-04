#!/usr/bin/env bash
# shellcheck disable=SC2120

Filters::toLowerCase() {
  if (($# == 1)); then
    Filters::toLowerCase <<<"$1"
  else
    tr '[:upper:]' '[:lower:]'
  fi
}
