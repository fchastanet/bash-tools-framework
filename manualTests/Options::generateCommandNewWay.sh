#!/usr/bin/env bash

rootDir="$(cd "$(readlink -e "${BASH_SOURCE[0]%/*}")/.." && pwd -P)"
export FRAMEWORK_ROOT_DIR="${rootDir}"
export _COMPILE_ROOT_DIR="${rootDir}"
srcDir="$(cd "${rootDir}/src" && pwd -P)"

# shellcheck source=src/Options/__all.sh
source "${srcDir}/Options/__all.sh"
# shellcheck source=/src/Log/__all.sh
source "${srcDir}/Log/__all.sh"

set -o errexit
set -o pipefail
export TMPDIR="/tmp"

# shellcheck source=/dev/null
source <(
  Options::generateGroup \
    --title "GLOBAL OPTIONS:" \
    --function-name groupGlobalOptions

  Options::generateOption \
    --help "help" \
    --group groupGlobalOptions \
    --alt "--help" \
    --alt "-h" \
    --callback helpCallback \
    --function-name optionHelp

  Options::generateOption \
    --help "verbose mode" \
    --group groupGlobalOptions \
    --variable-name "verbose" \
    --alt "--verbose" --alt "-v" \
    --function-name optionVerbose

  Options::generateOption \
    --variable-type String \
    --help "Set log level" \
    --group groupGlobalOptions \
    --variable-name "logLevel" \
    --alt "--log-level" \
    --function-name optionLogLevel

  Options::generateOption \
    --variable-type String \
    --help "set display level" \
    --group groupGlobalOptions \
    --variable-name "displayLevel" \
    --alt "--display-level" \
    --function-name optionDisplayLevel

  Options::generateOption \
    --help "Produce monochrome output." \
    --group groupGlobalOptions \
    --variable-name "noColor" \
    --alt "--no-color" \
    --function-name optionNoColor

  Options::generateOption \
    --help "Print version information and quit" \
    --group groupGlobalOptions \
    --alt "--version" \
    --callback versionCallback \
    --function-name optionVersion

  Options::generateOption \
    --variable-name "quiet" \
    --help "quiet mode" \
    --group groupGlobalOptions \
    --alt "--quiet" --alt "-q" \
    --function-name optionQuiet
)

declare -a options=(
  --author "[François Chastanet](https://github.com/fchastanet)"
  --source-file "${REPOSITORY_URL}/tree/master/${SRC_FILE_PATH}"
  --license "MIT License"
  --copyright "Copyright (c) 2022 François Chastanet"
  --version "${versionNumber}"
  optionHelp
  optionVersion
  optionQuiet
  optionNoColor
  optionLogLevel
  optionDisplayLevel
  optionVerbose
)

declare versionNumber="1.0"
declare help="lint awk files

Lint all files with .awk extension in current git folder.
Result in checkstyle format."
options+=(--help "${help}")

# shellcheck source=/dev/null
source <(
  Options::generateCommand "${options[@]}" \
    --command-name awkLint \
    --function-name awkLintCommand
)

awkLintCommand help
