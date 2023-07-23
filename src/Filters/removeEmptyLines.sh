#!/usr/bin/env bash

# remove empty lines and lines containing only spaces
Filters::removeEmptyLines() {
  awk NF "$@"
}
