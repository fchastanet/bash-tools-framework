#!/usr/bin/env bash

# @description ensure linux distribution is ubuntu
# @exitcode 1 if linux distribution is not ubuntu
Linux::requireUbuntu() {
  [[ "$(Linux::getDistributorId)" = "Ubuntu" ]]
}
