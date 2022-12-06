#!/usr/bin/env bash

alias import="__bash_framework__allowFileReloading=false Framework::importFilesOnce"
alias source="__bash_framework__allowFileReloading=true Framework::importOneOnce"
alias .="__bash_framework__allowFileReloading=true Framework::importOneOnce"
