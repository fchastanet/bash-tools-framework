#!/usr/bin/env bash

# test use to manually test when difficult to debug through bats
set -x
set -o errexit
set -o pipefail
ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)
srcDir="${ROOT_DIR}/src"

# shellcheck source=/src/Docker/testContainer.sh
source "${srcDir}/Docker/testContainer.sh"
# shellcheck source=/src/Log/displayInfo.sh
source "${srcDir}/Log/displayInfo.sh"
# shellcheck source=/src/Log/displayError.sh
source "${srcDir}/Log/displayError.sh"
# shellcheck source=/src/Log/displaySuccess.sh
source "${srcDir}/Log/displaySuccess.sh"
# shellcheck source=/src/Log/displayWarning.sh
source "${srcDir}/Log/displayWarning.sh"
# shellcheck source=/src/Log/logInfo.sh
source "${srcDir}/Log/logInfo.sh"
# shellcheck source=/src/Log/logError.sh
source "${srcDir}/Log/logError.sh"
# shellcheck source=/src/Log/logSuccess.sh
source "${srcDir}/Log/logSuccess.sh"
# shellcheck source=/src/Log/logWarning.sh
source "${srcDir}/Log/logWarning.sh"
# shellcheck source=/src/Log/logMessage.sh
source "${srcDir}/Log/logMessage.sh"
# shellcheck source=/src/Retry/parameterized.sh
source "${srcDir}/Retry/parameterized.sh"
# shellcheck source=/src/Assert/dirExists.sh
source "${srcDir}/Assert/dirExists.sh"

alias docker-compose="exit 1"
set -x
Docker::testContainer "/home/wsl/projects/bash-tools" "containerName" "title" "url"
