#!/usr/bin/env bash

# @description check if param is valid dns hostname
# @arg $1 dnsHostname:String the dns hostname
# @exitcode 1 if invalid hostname
Assert::dnsHostname() {
  [[ "$1" =~ ^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$ ]]
}
