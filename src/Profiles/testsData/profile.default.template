#!/bin/bash

if [[ -z "${CONFIG_LIST+xxx}" ]]; then
  CONFIG_LIST=()
fi

# profile to be used with configure
# create your own profile and comment the configuration you want to skip

CONFIG_LIST+=(
  Anacron
  "${AWS_AUTHENTICATOR}"
  BashProfile
  ZshProfile
  BashTools
  CodeCheckers
  Composer
  ComposerDependencies
  Font
  Fortune
  Git
  GitHook
  Hadolint
  Kubernetes
  # Mlocate deprecated in favor of fd (installed with Fzf dependency of BashProfile and ZshProfile)
  # contrary to Mlocate, fd does not need to maintain a db of files
  # Mlocate
  Motd
  NodeDependencies
  NodeNpm
  OpenVpn
  Oq
  Plantuml
  Ssh
  VsCode
  VsCodeExtensionProfiles

  # Dns not enabled by default as still experimental
  # use profile.dns.sh if you encounter some dns issues
  # Dns
)
