# Compilation tools

Compilation tools is made with these 2 commands:

- **compile** : Inlines all the functions used in the script given in parameter
- **constructBinFile** : create binary file from a srcFile

## 1. Why ?

Scripts that utilize multiple files are not easy to distribute. We usually
distribute those as archives and rely on the end user to unpack and run them
from a predetermined location. To improve the experience we can instead prepare
a single script with other files embedded inside it.

Here are the goals:

- The script should consist of a single file, making it easy to distribute
- The script should be copy-paste-able between systems and different editors,
  even if multiple hops are required
- Files being embedded can be binary files i.e. can contain non-printable
  characters
- bash functions reusability

The first requirement implies that we should somehow store the contents of other
files in our main script. The second requires us to avoid non-printable
characters, as they tend to cause problems when performing a copy-paste
operation. Especially when we are talking about sending such characters over
messaging programs.

## 2. Compile tool

This tool allows to detect all the framework functions used inside a given sh
file. All the functions matching the pattern `namespace::functionName` (we can
have several namespaces separated by the characters `::`) will be injected
inside a compiled file. The process is recursive so that every framework
functions used by imported framework functions will be imported as well (of
course only once).

You can see several examples of compiled files by checking
[src/\_binaries folder](src/_binaries). For example:

- `src/_binaries/frameworkLint.sh` generates the file `bin/frameworkLint`

<!-- markdownlint-capture -->
<!-- markdownlint-disable MD033 -->

### 2.1. <a name="embedInclude"></a>compiler - Embed::include

<!-- markdownlint-restore -->

A new feature in the compiler is the ability to embed files, directories or a
framework function Embed::include allows to:

- include a file(binary or not) as md5 encoded, the file can then be extracted
  using the automatically generated method Embed::extractFile_asName where
  asName is the name chosen above the orginal filemode will be restored after
  extraction. The variable embed_file_asName contains the targetted filepath.
- include a directory, the directory will be tar gz and added to the compiled
  file as md5 encoded string. The directory can then be extracted using the
  automatically generated method Embed::extractDir_asName where asName is the
  name chosen above. The variable embed_dir_asName contains the targetted
  directory path.
- include a bash framework function, a special binary file that simply calls
  this function will be automatically generated. This binary file will be added
  to the compiled file as md5 encoded string and will be automatically extracted
  to temporary directory and is callable directly using "asName" chosen above
  because path of the temporary directory is in the PATH variable.

## 3. ConstructBinFile tool

compile is almost never used alone but it can, ConstructBinFile allows to
generate a binary file using some metadata directly isinde the src file.

Eg:

```bash
#!/usr/bin/env bash
# BIN_FILE=${ROOT_DIR}/bin/binaryExample
# ROOT_DIR_RELATIVE_TO_BIN_DIR=..
# META_SCRIPT=MinimumRequirements
# INCLUDE "Backup::file" as backupFile
# INCLUDE "${ROOT_DIR}/bin/otherNeededBinary" AS "otherNeededBinary"

.INCLUDE "${ORIGINAL_TEMPLATE_DIR}/_includes/_header.tpl"

sudo "${embed_file_backupFile}" # ...
"${embed_file_otherNeededBinary}"
# ...
```

The above file header allows to generate the `bin/binaryExample` binary file. It
uses INCLUDE macro to allow the usage of Backup::file function as a binary named
backupFile that can even be called using `sudo`.

The srcFile should contains at least the metadata BIN_FILE and
ROOT_DIR_RELATIVE_TO_BIN_DIR at top of the bash script file (see example above).

### 3.1. ROOT_DIR_RELATIVE_TO_BIN_DIR metadata

Mandatory information allowing the compiler to deduce bash-tools-framework root
directory.

### 3.2. BIN_FILE metadata (optional)

allows to indicate where the resulting bin file will be generated if not
provided, the binary file will be copied to {binDir} without sh extension

### 3.3. INCLUDE metadata (optional)

Allows to embed files, directories or a framework function. The following syntax
can be used:

```bash
# INCLUDE "srcFile" AS "targetFile"
# INCLUDE "srcDir" AS "targetDir"
# INCLUDE namespace::functions AS "myFunction"
```

if INCLUDE metadata is provided, the file/dir provided will be added inside the
resulting bin file as a tar gz file(base64 encoded) and automatically extracted
when executed.

See [compiler - Embed::include](#embedInclude) above for more information.

### 3.4. META\_\* metadata (optional)

it is a metadata variable used during compilation time (not during execution),
it can be used to generate binary files based generic template files.
[see specific usage in bash-dev-env project](https://github.com/fchastanet/bash-dev-env).

## 4. .framework-config

The special file `.framework-config` allows to change some behaviors of the
compiler or the framework linter.

```bash
# describe the functions that will be skipped from being imported
FRAMEWORK_FUNCTIONS_IGNORE_REGEXP='^namespace::functions$|^Functions::myFunction$|^IMPORT::dir::file$|^Acquire::ForceIPv4$'
# describe the files that do not contain function to be imported
NON_FRAMEWORK_FILES_REGEXP="(.bats$|/testsData/|/_.sh$|/ZZZ.sh$|/__all.sh$|^src/_|^src/batsHeaders.sh$)"
# describe the files that are allowed to not have a function matching the filename
FRAMEWORK_FILES_FUNCTION_MATCHING_IGNORE_REGEXP="^bin/|^\.framework-config$|^build.sh$|^tests/|\.tpl$|testsData/binaryFile$"
# Source directories
FRAMEWORK_SRC_DIRS=()

```

## 5. FrameworkLint

Lint files of the current repository

- check if all namespace::functions are existing in the framework
- check that function defined in a .sh is correctly named

This linter is used as one the precommit hooks, see
[.pre-commit-config.yaml](.pre-commit-config.yaml).

## 6. Acknowledgements

I want to thank a lot Michał Zieliński(Tratif company) for this wonderful
article that helped me a lot in the conception of the file/dir/framework
function embedding feature.

for more information see
[Bash Tips #6 – Embedding Files In A Single Bash Script](https://blog.tratif.com/2023/02/17/bash-tips-6-embedding-files-in-a-single-bash-script/)
