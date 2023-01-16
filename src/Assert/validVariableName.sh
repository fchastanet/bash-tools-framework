#!/usr/bin/env bash

Assert::validVariableName() {
  echo "$1" | LC_ALL=POSIX grep -E -q '^[A-Za-z_0-9:]+$'
}
