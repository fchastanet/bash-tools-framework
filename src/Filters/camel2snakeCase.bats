#!/usr/bin/env bash

vendorDir="$(cd "${BATS_TEST_DIRNAME}/../.." && pwd -P)/vendor"
srcDir="$(cd "${BATS_TEST_DIRNAME}/.." && pwd -P)"
set -o errexit
set -o pipefail

load "${vendorDir}/bats-support/load.bash"
load "${vendorDir}/bats-assert/load.bash"
load "${vendorDir}/bats-mock-Flamefire/load.bash"

# shellcheck source=src/Filters/camel2snakeCase.sh
source "${BATS_TEST_DIRNAME}/camel2snakeCase.sh"
# shellcheck source=/src/Filters/toLowerCase.sh
source "${srcDir}/Filters/toLowerCase.sh"

function Filters::camel2snakeCaseSimple { #@test
  echo "TEST" | {
    run Filters::camel2snakeCase
    assert_output "test"
  }
}

function Filters::camel2snakeCaseSeveralUppercase { #@test
  echo "camelCASE2SNAKEcase" | {
    run Filters::camel2snakeCase
    # cspell:disable-next-line
    assert_output "camel_case2snakecase"
  }
}

function Filters::camel2snakeCase2Blocks { #@test
  echo "camelCASE-SNAKEcase" | {
    run Filters::camel2snakeCase
    # cspell:disable-next-line
    assert_output "camel_case_snakecase"
  }
}

function Filters::camel2snakeCaseJira { #@test
  echo "featureTEST/TOOLS-1456" | {
    run Filters::camel2snakeCase
    assert_output "feature_test/tools_1456"
  }
}

function Filters::camel2snakeCaseJiraOrigin { #@test
  echo "origin/featureTEST/TOOLS-1456" | {
    run Filters::camel2snakeCase
    assert_output "origin/feature_test/tools_1456"
  }
}

function Filters::camel2snakeCaseJiraAt { #@test
  echo "origin@featureTEST@TOOLS-1456" | {
    run Filters::camel2snakeCase
    assert_output "origin@feature_test@tools_1456"
  }
}

function Filters::camel2snakeCaseJiraSeveralSpecialCharacters { #@test
  echo 'origin`$~featureTEST@/ç^TOOLS-1456' | {
    run Filters::camel2snakeCase
    assert_output 'origin`$~feature_test@/ç^tools_1456'
  }
}

function Filters::camel2snakeCaseAlreadySnake { #@test
  echo "training_path_visualizer" | {
    run Filters::camel2snakeCase
    assert_output "training_path_visualizer"
  }
}

function Filters::camel2snakeCaseKebabCase { #@test
  echo "innovation/vuecli-with-web" | {
    run Filters::camel2snakeCase
    assert_output "innovation/vuecli_with_web"
  }
}
