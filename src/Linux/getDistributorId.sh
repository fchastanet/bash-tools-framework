#!/usr/bin/env bash

# @description retrieve linux distributor id
# @noargs
# @exitcode 1 if lsb_release fails or not found
# @stdout the linux distributor id
Linux::getDistributorId() {
  lsb_release -a 2>/dev/null | sed -En 's/Distributor ID:[ \t]+(.+)/\1/p'
}
