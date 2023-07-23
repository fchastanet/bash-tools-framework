#!/usr/bin/env bash

# check if param is valid dns hostname
# @param $1 the dns hostname
# @return 1 on error
Assert::dnsHostname() {
  [[ "$1" =~ ^[A-Za-z0-9-]+(\.[A-Za-z0-9-]+)+$ ]]
}
