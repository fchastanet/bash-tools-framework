#!/usr/bin/env bash

# @description retrieve linux distribution code name
# @noargs
# @exitcode 1 if lsb_release fails or not found
# @stdout the linux distribution code name
Linux::getCodename() {
  (
    source /etc/os-release
    echo "${VERSION_CODENAME}"
  )
}
