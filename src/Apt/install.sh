#!/usr/bin/env bash

Apt::install() {
  Retry::default apt-get install -y -q "$@"
}
