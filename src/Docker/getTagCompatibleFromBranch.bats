#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

# shellcheck source=/src/Docker/getTagCompatibleFromBranch.sh
source "${BATS_TEST_DIRNAME}/getTagCompatibleFromBranch.sh"
# shellcheck source=/src/Filters/toLowerCase.sh
source "${srcDir}/Filters/toLowerCase.sh"
# shellcheck source=/src/Filters/camel2snakeCase.sh
source "${srcDir}/Filters/camel2snakeCase.sh"

function Docker::getTagCompatibleFromBranchMaster { #@test
  echo "origin/master" | {
    run Docker::getTagCompatibleFromBranch
    assert_output "master"
  }
}
function Docker::getTagCompatibleFromBranchFeatureBranch { #@test
  echo "origin/feature/My-beautiful-feature" | {
    run Docker::getTagCompatibleFromBranch
    assert_output "feature_my_beautiful_feature"
  }
}
function Docker::getTagCompatibleFromBranchReplaceCharacter { #@test
  echo "origin/feature/My-beautiful-feature" | {
    run Docker::getTagCompatibleFromBranch "#"
    assert_output "feature#my_beautiful_feature"
  }
}

function Docker::getTagCompatibleFromBranchSpecialCharacter { #@test
  echo "origin@feature@My-beautiful-feature" | {
    run Docker::getTagCompatibleFromBranch
    assert_output "origin@feature@my_beautiful_feature"
  }
}
