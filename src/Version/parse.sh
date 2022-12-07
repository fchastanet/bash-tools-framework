#!/usr/bin/env bash

# filter to keep only version number from a string
# @stdin the string to parse
Version::parse() {
  sed -nre 's/[^0-9]*(([0-9]+\.)*[0-9]+).*/\1/p'
}