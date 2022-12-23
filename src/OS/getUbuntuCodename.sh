#!/usr/bin/env bash

OS::getUbuntuCodename() {
  lsb_release -a 2>/dev/null | sed -En 's/Codename:[ \t]+(.+)/\1/p'
}
