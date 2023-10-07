# function group

## Description

`Options::generateGroup` generated this function that allows to group options.

The function generated can be use with `--group` option of the function
`Options::generateOption` in order to group options when using
`Options::generateCommand`.

## Syntax

```text
Usage: groupFunction COMMAND
```

**Commands:**

_help_

> generates this group help (will actually eval helpTpl command)

_helpTpl_ (internal)

> generates this group help in bash script format (using echo/printf).

_id_

> displays auto generated unique id or function name provided by
> `--function-name` option

## Example

This script:

```bash
Options::generateGroup \
  --title "Global options" \
  --help "help"
```

will generate this
[generated function](https://github.com/fchastanet/bash-tools-framework/blob/master/src/Options/testsData/generateGroup.caseGroupOptionValid.sh).
