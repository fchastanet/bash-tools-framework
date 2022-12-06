#!/usr/bin/env bash

Apt::update() {
  Retry::default apt-get update -y --fix-missing -o Acquire::ForceIPv4=true
}
