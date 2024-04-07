#!/bin/bash

# @description equivalent of awk 'NR==1{print $1}'
# allows to retrieve the first field of a piped input
Filters::firstField() {
  # shellcheck disable=SC2086
  (
    IFS=' ' read -r -a i
    echo ${i[0]:-}
    exit 0
  )
}
