#!/usr/bin/env bash

# shellcheck disable=SC2154
Docker::buildPushDockerImage \
  "${optionVendor}" \
  "${optionBashVersion}" \
  "${optionBashBaseImage}" \
  "${optionPush}" \
  "${optionTraceVerbose}"
