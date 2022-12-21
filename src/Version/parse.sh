#!/usr/bin/env bash

# filter to keep only version number from a string
# @stdin the string to parse
Version::parse() {
  sed -En 's/[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p' | head -n1
}
