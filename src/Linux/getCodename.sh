#!/usr/bin/env bash

# @description retrieve linux distribution code name
# @noargs
# @exitcode 1 if lsb_release fails or not found
# @stdout the linux distribution code name
Linux::getCodename() {
  lsb_release -a 2>/dev/null | sed -En 's/Codename:[ \t]+(.+)/\1/p'
}
