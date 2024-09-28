#!/usr/bin/env bash

# shellcheck disable=SC2034,SC2154

Linux::requireJqCommand
Linux::requireExecutedAsUser

mkdir -p "${FRAMEWORK_ROOT_DIR}/vendor" || true
Bats::installRequirementsIfNeeded "${FRAMEWORK_ROOT_DIR}"
Softwares::installHadolint
Softwares::installShellcheck
