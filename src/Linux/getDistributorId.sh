#!/usr/bin/env bash

# @description retrieve linux distributor id
# @noargs
# @exitcode 1 if lsb_release fails or not found
# @stdout the linux distributor id
Linux::getDistributorId() {
  (
    source /etc/os-release
    echo "${ID}"
  )
}
