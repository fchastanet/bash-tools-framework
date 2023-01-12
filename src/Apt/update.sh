#!/usr/bin/env bash

Apt::update() {
  Retry::default sudo apt-get update -y --fix-missing -o Acquire::ForceIPv4=true
}
