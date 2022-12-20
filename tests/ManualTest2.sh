#!/usr/bin/env bash

# test use to manually test when difficult to debug through bats
set -x
ROOT_DIR=$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)
srcDir="${ROOT_DIR}/src"

# shellcheck source=src/Docker/pullImage.sh
source "${srcDir}/Docker/pullImage.sh"
# shellcheck source=src/Filters/toLowerCase.sh
source "${srcDir}/Filters/toLowerCase.sh"
# shellcheck source=src/Log/displayError.sh
source "${srcDir}/Log/displayError.sh"
# shellcheck source=src/Log/logError.sh
source "${srcDir}/Log/logError.sh"
# shellcheck source=src/Log/logMessage.sh
source "${srcDir}/Log/logMessage.sh"

set -x
Docker::pullImage "ubuntu" "invalid" "latest"
