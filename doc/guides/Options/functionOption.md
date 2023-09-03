# function Option

## Description

`Options::generateOption` has generated this Option function that can display
help and parse the configured option. Several commands are available on option
function:

- variableName
- variableType (Boolean, String, StringArray)
- type (Option)
- alts
- helpAlt
- export

## Syntax

```text
Usage: optionFunction COMMAND
```

**Commands:**

_help_

> generates this option help (will actually eval helpTpl command)

_helpTpl_ (internal)

> generates this option help in bash script format (using echo/printf).

_parse_

> parses this configured option _Eg.:_ example that will have the effect to fill
> the variable that has been declared when using
> `Options::generateOption --variable-name "verbose" ...`

```bash
optionVerbose parse --verbose
echo "${verbose}" # will print 1
```

_variableName_

> display the configured variable name.

_type_

> display `Option`.

_variableType_

> display the configured option type (`Boolean`, `String` or `StringArray`).

_oneLineHelp_

> display option help one one line (can be useful for debugging purpose).

_alts_

> display option alternatives (option `--alt` provided to
> `Options::generateOption`) (one by line)

_helpAlt_

> display alt string depending on options (min, max, alt, ...) Eg1:
> `[--help|-h]` Eg2: `[--src-dir|-s <String>]`

_groupId_

> display the configured `--group` option (name of the group function) or
> `__default` if none provided

_export_

> exports all the configuration variables of this argument:
>
> - type
> - variableType
> - variableName
> - offValue
> - onValue
> - defaultValue
> - min
> - max
> - authorizedValues
> - alts
> - callback

## Example

This script:

```bash
Options::generateOption \
  --variable-type StringArray \
  --variable-name "srcDirs" \
  --alt "--src-dir" --alt "-s" \
  --max -1 \
  --callback srcDirsCallback \
  --function-name "Options::option"
```

will generate this
[generated function](https://github.com/fchastanet/bash-tools-framework/blob/master/src/Options/testsData/generateOption.caseStringArray6.sh).
