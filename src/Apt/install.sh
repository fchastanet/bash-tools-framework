#!/usr/bin/env bash

Apt::install() {
  Retry::default sudo apt-get install -y -q "$@"
}
