#!/usr/bin/env bash

# shellcheck disable=SC2120
Filters::commentLines() {
  grep -vxE "[[:blank:]]*(${commentLinePrefix:-#}.*)?" "$@" || test $? = 1
}
