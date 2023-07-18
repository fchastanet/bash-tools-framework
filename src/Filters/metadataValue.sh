#!/usr/bin/env bash

# retrieve the metadata value for given metadata name
# @param {string} metaDataName $1 the metadata name to retrieve
# @output the value after equals sign (spaces and quotes trimmed)
# @return 1 if the metadata is not found
Filters::metadataValue() {
  local metaDataName="$1"
  shift || true
  grep -m 1 -E "^# ${metaDataName}[ \t]*=" "$@" |
    # https://regex101.com/r/1opgGH/1
    sed -E $'s/^#[^=]+=[ \t"\']*(.*)$/\\1/' |
    sed -E $'s/[ \t"\']*$//'
}
