#!/usr/bin/env bash

Assert::validVariableName() {
  echo "$1" | grep -E -q '^[A-Za-z_0-9:]+$' || return 1
}
