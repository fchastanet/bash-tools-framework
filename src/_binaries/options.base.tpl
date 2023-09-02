%# Needed variables
%# - versionNumber
%
  optionGroup="$(Options::generateGroup \
    --title "COMMON OPTIONS:" \
  )"
  Options::sourceFunction "${optionGroup}"

  helpCallback() { :; }
  optionHelp="$(Options::generateOption \
    --variable-type Boolean \
    --help "help" \
    --group "${optionGroup}" \
    --variable-name "help" \
    --alt "--help" \
    --alt "-h" \
    --callback helpCallback
  )"
  Options::sourceFunction "${optionHelp}"

  optionVerbose="$(Options::generateOption \
    --help "verbose mode" \
    --group "${optionGroup}" \
    --variable-name "verbose" \
    --alt "--verbose" --alt "-v"
  )"
  Options::sourceFunction "${optionVerbose}"

  optionLogLevel="$(Options::generateOption \
    --variable-type String \
    --help "Set log level" \
    --group "${optionGroup}" \
    --variable-name "logLevel" \
    --alt "--log-level" \
  )"
  Options::sourceFunction "${optionLogLevel}"

  optionDisplayLevel="$(Options::generateOption \
    --variable-type String \
    --help "set display level" \
    --group "${optionGroup}" \
    --variable-name "displayLevel" \
    --alt "--display-level" \
  )"
  Options::sourceFunction "${optionDisplayLevel}"

  optionNoColor="$(Options::generateOption \
    --variable-type Boolean \
    --help "Produce monochrome output." \
    --group "${optionGroup}" \
    --variable-name "noColor" \
    --alt "--no-color" \
  )"
  Options::sourceFunction "${optionNoColor}"

  versionCallback() {
    :
  }
  optionVersion="$(Options::generateOption \
    --variable-type Boolean \
    --help "Print version information and quit" \
    --group "${optionGroup}" \
    --variable-name "version" \
    --alt "--version" \
    --callback versionCallback \
  )"
  Options::sourceFunction "${optionVersion}"

  optionQuiet="$(Options::generateOption \
    --variable-name "quiet" \
    --help "quiet mode" \
    --group "${optionGroup}" \
    --alt "--quiet" --alt "-q" \
  )"
  Options::sourceFunction "${optionQuiet}"

  declare -a options=(
    --author "[François Chastanet](https://github.com/fchastanet)"
    --source-file "${REPOSITORY_URL}/tree/master/${SRC_FILE_PATH}"
    --license "MIT License"
    --copyright "Copyright (c) 2022 François Chastanet"
    --version "${versionNumber}"
    ${optionHelp}
    ${optionVersion}
    ${optionQuiet}
    ${optionNoColor}
    ${optionLogLevel}
    ${optionDisplayLevel}
    ${optionVerbose}
  )
%

versionCallback() {
  echo "${SCRIPT_NAME} version <% ${versionNumber} %>"
  exit 0
}
