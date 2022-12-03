#!/usr/bin/env bash

OS::getUbuntuCodename() {
  lsb_release -a 2>/dev/null | sed -rn 's/Codename:[ \t]+(.+)/\1/p'
}
