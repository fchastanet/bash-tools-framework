#!/usr/bin/env bash

UI::displayLine() {
  local repeatChar="$1"
  local length="$2"
  head -c "${length}" </dev/zero | tr '\0' "${repeatChar}"
  echo
}
