#!/usr/bin/env bash

# @see https://unix.stackexchange.com/a/653883
Filters::trimEmptyLines() {
  awk '
    NF {print saved $0; saved = ""; started = 1; next}
    started {saved = saved $0 ORS}
  '
}
