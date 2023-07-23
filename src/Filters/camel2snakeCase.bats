#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=src/Filters/camel2snakeCase.sh
source "${BATS_TEST_DIRNAME}/camel2snakeCase.sh"
# shellcheck source=/src/Filters/toLowerCase.sh
source "${srcDir}/Filters/toLowerCase.sh"

function Filters::camel2snakeCase::Simple { #@test
  echo "TEST" | {
    run Filters::camel2snakeCase
    assert_output "test"
  }
}

function Filters::camel2snakeCase::SeveralUppercase { #@test
  echo "camelCASE2SNAKEcase" | {
    run Filters::camel2snakeCase
    # cspell:disable-next-line
    assert_output "camel_case2snakecase"
  }
}

function Filters::camel2snakeCase::2Blocks { #@test
  echo "camelCASE-SNAKEcase" | {
    run Filters::camel2snakeCase
    # cspell:disable-next-line
    assert_output "camel_case_snakecase"
  }
}

function Filters::camel2snakeCase::Jira { #@test
  echo "featureTEST/TOOLS-1456" | {
    run Filters::camel2snakeCase
    assert_output "feature_test/tools_1456"
  }
}

function Filters::camel2snakeCase::JiraOrigin { #@test
  echo "origin/featureTEST/TOOLS-1456" | {
    run Filters::camel2snakeCase
    assert_output "origin/feature_test/tools_1456"
  }
}

function Filters::camel2snakeCase::JiraAt { #@test
  echo "origin@featureTEST@TOOLS-1456" | {
    run Filters::camel2snakeCase
    assert_output "origin@feature_test@tools_1456"
  }
}

function Filters::camel2snakeCase::JiraSeveralSpecialCharacters { #@test
  echo 'origin`$~featureTEST@/ç^TOOLS-1456' | {
    run Filters::camel2snakeCase
    assert_output 'origin`$~feature_test@/ç^tools_1456'
  }
}

function Filters::camel2snakeCase::AlreadySnake { #@test
  echo "training_path_visualizer" | {
    run Filters::camel2snakeCase
    assert_output "training_path_visualizer"
  }
}

function Filters::camel2snakeCase::KebabCase { #@test
  echo "innovation/vuecli-with-web" | {
    run Filters::camel2snakeCase
    assert_output "innovation/vuecli_with_web"
  }
}

function Filters::camel2snakeCase::NoMatch { #@test
  echo "" | {
    run Filters::camel2snakeCase
    assert_output ""
  }
}
