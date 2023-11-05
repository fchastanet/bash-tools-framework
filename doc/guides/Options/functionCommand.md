# function Command

## Description

`Options::generateCommand` generated this function that allows to display help
and parse all arguments or options at once.

## Syntax

```text
Usage: commandFunction COMMAND
```

**Commands:**

_help_

> generates this command help

_parse_

> parses all the arguments using the arguments/options declared using
>
> - `Options::generateArg`
> - `Options::generateOption`

### Example of a generated function

The call to following script:

```bash
source <(
Options::generateOption \
  --variable-type Boolean \
  --help "help" \
  --alt "--help" --alt "-h" \
  --callback helpCallback \
  --functionName optionHelp

Options::generateOption \
  --variable-type StringArray \
  --help "provide the directory where to find the functions source code." \
  --variable-name "srcDirs" \
  --alt "--src-dirs" --alt "-s" \
  --functionName optionSrcDirs

Options::generateGroup \
  --title "Command global options" \
  --help "The Console component adds some predefined options to all commands:" \
  --functionName groupGlobalOptions

Options::generateOption \
  --help "verbose mode" \
  --alt "--verbose" --alt "-v" \
  --group groupGlobalOptions \
  --variable-name "verbose" \
  --functionName optionVerbose

Options::generateOption \
  --help "quiet mode" \
  --group groupGlobalOptions \
  --variable-name "quiet" \
  --alt "--quiet" --alt "-q" \
  --functionName optionQuiet

Options::generateArg \
  --variable-name "srcFile" \
  --callback srcFileCallback \
  --functionName argSrcFile

Options::generateArg \
  --variable-name "destFiles" \
  --max 3 \
  --callback destFilesCallback \
  --functionName argDestFiles
)

Options::generateCommand --help "super command" \
  optionVerbose \
  optionQuiet \
  optionHelp \
  optionSrcDirs \
  argSrcFile \
  argDestFiles
```

will generate this
[generated function](https://github.com/fchastanet/bash-tools-framework/blob/master/src/Options/testsData/generateCommand.case6.sh).

The generated function will then be able to generate this
[generated help](https://github.com/fchastanet/bash-tools-framework/blob/master/src/Options/testsData/generateCommand.case6.expected.help)
