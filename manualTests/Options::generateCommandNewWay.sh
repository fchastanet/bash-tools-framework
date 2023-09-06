#!/usr/bin/env bash

rootDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)"
export FRAMEWORK_ROOT_DIR="${rootDir}"
export _COMPILE_ROOT_DIR="${rootDir}"
srcDir="$(cd "${rootDir}/src" && pwd -P)"

# shellcheck source=src/Options/__all.sh
source "${srcDir}/Options/__all.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"
Log::requireLoad

set -o errexit
set -o pipefail
export TMPDIR="/tmp"

# shellcheck source=/dev/null
source <(
  Options::generateGroup \
    --title "GLOBAL OPTIONS:" \
    --function-name groupGlobalOptionsFunction || exit 2

  Options::generateOption \
    --help "help" \
    --group groupGlobalOptionsFunction \
    --variable-name "helpOption" \
    --alt "--help" \
    --alt "-h" \
    --callback helpCallback \
    --function-name optionHelpFunction || exit 2

  Options::generateOption \
    --help "verbose mode" \
    --variable-name "verboseOption" \
    --group groupGlobalOptionsFunction \
    --alt "--verbose" --alt "-v" \
    --function-name optionVerboseFunction || exit 3

  Options::generateOption \
    --variable-type String \
    --variable-name "logLevelOption" \
    --help "Set log level" \
    --group groupGlobalOptionsFunction \
    --alt "--log-level" \
    --function-name optionLogLevelFunction || exit 4

  Options::generateOption \
    --variable-type String \
    --variable-name "displayLevelOption" \
    --help "set display level" \
    --group groupGlobalOptionsFunction \
    --alt "--display-level" \
    --function-name optionDisplayLevelFunction || exit 5

  Options::generateOption \
    --help "Produce monochrome output." \
    --variable-name "noColorOption" \
    --group groupGlobalOptionsFunction \
    --alt "--no-color" \
    --function-name optionNoColorFunction || exit 6

  Options::generateOption \
    --help "Print version information and quit" \
    --variable-name "versionOption" \
    --group groupGlobalOptionsFunction \
    --alt "--version" \
    --callback versionCallback \
    --function-name optionVersionFunction || exit 7

  Options::generateOption \
    --variable-name "quietOption" \
    --help "quiet mode" \
    --group groupGlobalOptionsFunction \
    --alt "--quiet" --alt "-q" \
    --function-name optionQuietFunction || exit 8

  Options::generateArg \
    --variable-name "srcFile" \
    --function-name srcFileArgFunction || exit 9
)

declare -a options=(
  --author "[François Chastanet](https://github.com/fchastanet)"
  --source-file "${REPOSITORY_URL}/tree/master/${SRC_FILE_PATH}"
  --license "MIT License"
  --copyright "Copyright (c) 2022 François Chastanet"
  --version "${versionNumber}"
  optionHelpFunction
  optionVersionFunction
  optionQuietFunction
  optionNoColorFunction
  optionLogLevelFunction
  optionDisplayLevelFunction
  optionVerboseFunction
  srcFileArgFunction
)

declare versionNumber="1.0"
declare help="lint awk files

Lint all files with .awk extension in current git folder.
Result in checkstyle format."
options+=(--help "${help}")

unknownArgumentCallback() {
  echo "unknown argument $1"
}

# shellcheck source=/dev/null
source <(
  Options::generateCommand "${options[@]}" \
    --command-name awkLint \
    --unknown-argument-callback unknownArgumentCallback \
    --function-name awkLintCommand
) || exit 10

set -x
awkLintCommand parse "$@"
