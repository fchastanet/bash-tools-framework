%# Needed variables
%# - versionNumber
%
  # shellcheck source=/dev/null
  source <(
    Options::generateGroup \
      --title "GLOBAL OPTIONS:" \
      --function-name groupGlobalOptions

    Options::generateOption \
      --help "help" \
      --group groupGlobalOptions \
      --variable-name "help" \
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
      --variable-name "version" \
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
%

versionCallback() {
  echo "${SCRIPT_NAME} version <% ${versionNumber} %>"
  exit 0
}
