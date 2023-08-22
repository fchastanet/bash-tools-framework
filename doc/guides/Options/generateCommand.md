# Command generation

```bash
declare commandForm=<% Options::generateCommand \
  --help "Command help" \
  --version "version 1.0" \
  --author "author is me" \
  --command-name "myCommand" \
  --License "MIT License" \
  --copyright "Copyright" \
  --template "path/to/template.tpl" \
  --error-if-repeated-options
%>
```

**Description**

Generates a function that allows to manipulate a command and its options.

**Syntax**

```text
Usage:  Options::generateCommand [OPTIONS]

Options::generateCommand
  --help <String|Function>
  [--command-name <String|Function>]
  [--help-version <String|Function>]
  [--help-author <String|Function>]
  [--help-License <String|Function>]
  [--help-copyright <String|Function>]
  [--help-template <String>]
  [--error-if-repeated-options]
```

**Mandatory Options:**

`--help <String|Function>`

> provides command description help

**Options:**

`--command-name <String|Function>` _(optional)_

> provides the command name. By default the name of current command file without
> path

`--help-version <String|Function>` _(optional)_

> provides version section help. Section not generated if not provided.

`--help-author <String|Function>` _(optional)_

> provides author section help. Section not generated if not provided.

`--help-License <String|Function>` _(optional)_

> provides License section help Section not generated if not provided.

`--help-copyright <String|Function>` _(optional)_

> provides copyright section help Section not generated if not provided.

`--help-template <String>` _(optional)_

> if you want to override the default template used to generate the help

`--error-if-repeated-options` _(optional)_

> exists with error code 1 if a unique mode option (Boolean, String) are
> repeated several times.

**Exit status:**

_Exit code 1_

> If function provided does not match any existing function in compiler srcDirs,
> the command fails with exit code 1. Bash framework Function naming convention
> are the only function supported in arguments.
