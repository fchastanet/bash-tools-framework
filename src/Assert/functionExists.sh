#!/usr/bin/env bash

Assert::functionExists() {
  declare -F "$1" >/dev/null
}
