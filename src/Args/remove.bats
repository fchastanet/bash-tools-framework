#!/usr/bin/env bash

# shellcheck source=src/batsHeaders.sh
source "$(cd "${BATS_TEST_DIRNAME}/.." && pwd)/batsHeaders.sh"

function Args::remove::noArg { #@test
  set --
  # shellcheck source=src/Args/remove.sh
  longArg="--verbose" shortArg="-v" source "${srcDir}/Args/remove.sh"
  [[ "$#" = "0" ]]
}

function Args::remove::noVerboseArg { #@test
  set -- --arg1 --arg2 fixedArg
  # shellcheck source=src/Args/remove.sh
  longArg="--verbose" shortArg="-v" source "${srcDir}/Args/remove.sh"
  [[ "$#" = "3" ]]
  [[ "$1" = "--arg1" ]]
  [[ "$2" = "--arg2" ]]
  [[ "$3" = "fixedArg" ]]
}

function Args::remove::shortVerboseArg { #@test
  set -- --arg1 --arg2 fixedArg -v
  # shellcheck source=src/Args/remove.sh
  longArg="--verbose" shortArg="-v" source "${srcDir}/Args/remove.sh"
  [[ "$#" = "3" ]]
  [[ "$1" = "--arg1" ]]
  [[ "$2" = "--arg2" ]]
  [[ "$3" = "fixedArg" ]]
}

function Args::remove::longVerboseArg { #@test
  set -- --arg1 --arg2 fixedArg --verbose
  # shellcheck source=src/Args/remove.sh
  longArg="--verbose" shortArg="-v" source "${srcDir}/Args/remove.sh"
  [[ "$#" = "3" ]]
  [[ "$1" = "--arg1" ]]
  [[ "$2" = "--arg2" ]]
  [[ "$3" = "fixedArg" ]]
}

function Args::remove::noShortArg { #@test
  set -- --arg1 --arg2 fixedArg --verbose
  # shellcheck source=src/Args/remove.sh
  longArg="--verbose" shortArg="" source "${srcDir}/Args/remove.sh"
  [[ "$#" = "3" ]]
  [[ "$1" = "--arg1" ]]
  [[ "$2" = "--arg2" ]]
  [[ "$3" = "fixedArg" ]]
}

function Args::remove::noLongArg { #@test
  set -- --arg1 --arg2 fixedArg -v
  # shellcheck source=src/Args/remove.sh
  longArg="" shortArg="-v" source "${srcDir}/Args/remove.sh"
  [[ "$#" = "3" ]]
  [[ "$1" = "--arg1" ]]
  [[ "$2" = "--arg2" ]]
  [[ "$3" = "fixedArg" ]]
}

function Args::remove::multipleSameArgs { #@test
  set -- --verbose --arg1 -v --arg2 --verbose fixedArg -v fixedArg2
  # shellcheck source=src/Args/remove.sh
  longArg="--verbose" shortArg="-v" source "${srcDir}/Args/remove.sh"
  [[ "$#" = "4" ]]
  [[ "$1" = "--arg1" ]]
  [[ "$2" = "--arg2" ]]
  [[ "$3" = "fixedArg" ]]
  [[ "$4" = "fixedArg2" ]]
}
