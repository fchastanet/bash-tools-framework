# function Option

Several commands are available on option function:

- parse
- help (will actually eval helpTpl command)
- helpTpl (internal)
- variableName
- variableType (Boolean, String, StringArray)
- type (Option)
- alts
- helpAlt
- export

## 4.2.1. function Option - parse

The option function generated will help you to parse options provided to the
function using parse command.

_Eg.:_ example that will have the effect to fill the variable that has been
declared when using `Options::generate --variable-name "verbose" ...`

```bash
optionVerbose parse --verbose
echo "${verbose}" # will print 1
```

## 4.2.2. function Option - help

The help command will help you generate the help associated to the function.

```bash
optionVerbose help
```

will print

```text
--verbose|-v display more information about processed files
```
