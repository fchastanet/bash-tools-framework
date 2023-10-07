#!/usr/bin/env bash

# @description assert alt value is correct
# @arg $1 altValue:String the alt option
# @exitcode 1 if alt is invalid
Options::assertAlt() {
  [[ "$1" =~ ^[-A-Za-z0-9]+$ ]]
}
