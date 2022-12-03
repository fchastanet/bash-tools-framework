---
title: 'The commands'
permalink: /commands
---

# The commands

- [1. bin/gitRenameBranch](#1-bingitrenamebranch)
- [2. bin/dbQueryAllDatabases](#2-bindbqueryalldatabases)
- [3. bin/dbScriptAllDatabases](#3-bindbscriptalldatabases)
- [4. bin/dbImport](#4-bindbimport)
- [5. bin/dbImportProfile](#5-bindbimportprofile)
- [6. bin/cli](#6-bincli)
- [7. bin/gitIsAncestorOf](#7-bingitisancestorof)
- [8. bin/mysql2puml](#8-binmysql2puml)

## 1. bin/gitRenameBranch

**Help**

```text
@@@gitRenameBranch_help@@@
```

## 2. bin/dbQueryAllDatabases

Execute a query on multiple database in order to generate a report, query can be
parallelized on multiple databases

```bash
bin/dbQueryAllDatabases -e localhost-root conf/dbQueries/databaseSize.sql
```

**Help**

```text
@@@dbQueryAllDatabases_help@@@
```

## 3. bin/dbScriptAllDatabases

Allow to execute a script on each database of specified mysql server

```bash
bin/dbScriptAllDatabases -d localhost-root dbCheckStructOneDatabase
```

or specified db only

```bash
bin/dbScriptAllDatabases -d localhost-root dbCheckStructOneDatabase db
```

launch script in parallel on multiple db at once

```bash
bin/dbScriptAllDatabases --jobs 10 -d localhost-root dbCheckStructOneDatabase
```

**Help:**

```text
@@@dbScriptAllDatabases_help@@@
```

## 4. bin/dbImport

Import default source dsn/db ExampleDbName into default target dsn/db
ExampleDbName

```bash
dbImport ExampleDbName
```

Ability to import db from dump stored on aws the dump file should have this name
`<fromDbName>.tar.gz` and stored on AWS location defined by S3_BASE_URL env
variable (see tests/data/.env file)

```bash
dbImport --from-aws ExampleDbName.tar.gz
```

It allows also to dump from source database and import it into target database.
Providing --profile option **dumps** only the tables selected. Providing
--tables option **imports** only the tables selected.

The following command will dump full structure and data of fromDb but will
insert only the data from tableA and tableB, full structure will be inserted
too. Second call to this command skip the dump as dump has been saved the first
time. Note that table A and table B are truncated on target database before
being imported.

```bash
dbImport --from-dsn default.remote --target-dsn default.local -p all fromDb targetDB --tables tableA,tableB
```

**Help**

```text
@@@dbImport_help@@@
```

## 5. bin/dbImportProfile

Import remote db into local db

```bash
dbImportProfile --from-dsn default.local MY_DB --ratio 45
```

Ability to generate profile that can be used in dbImport to filter out tables
bigger than given ratio (based on biggest table size). Profile is automatically
saved in ${HOME}/.bash-tools/dbImportProfiles with this format `auto*<dsn>*<db>`
**eg:** auto_default.local_MY_DB

**Help**

```text
@@@dbImportProfile_help@@@
```

## 6. bin/cli

**Help**

```text
@@@cli_help@@@
```

easy connection to docker container

**Example 1: open bash on a container named web**

```bash
cli web
```

will actually execute this command : MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='\*'
docker exec -it -e COLUMNS="$(tput cols)" -e LINES="$(tput lines)" --user=
apache2 //bin/bash

**Example 2: connect to mysql container with root user**

```bash
cli mysql root bash
```

will actually execute this command : MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='\*'
docker exec -e COLUMNS="$(tput cols)" -e LINES="$(tput lines)" -it --user=root
project-mysql bash

**Example 3: connect to mysql server in order to execute a query**

will actually execute this command : MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='\*'
docker exec -it -e COLUMNS="$(tput cols)" -e LINES="$(tput lines)" --user=mysql
project-mysql //bin/bash -c 'mysql -h127.0.0.1 -uroot -proot -P3306'

**Example 4: pipe sql command to mysql container**

```bash
echo 'SELECT
  table_schema AS "Database",
  ROUND(SUM(data_length + index_length) / 1024 / 1024, 2) AS "Size (MB)"
FROM information_schema.TABLES' | bin/cli mysql
```

will actually execute this command : MSYS_NO_PATHCONV=1 MSYS2_ARG_CONV_EXCL='\*'
docker exec -i -e COLUMNS="$(tput cols)" -e LINES="$(tput lines)" --user=mysql
project-mysql //bin/bash -c 'mysql -h127.0.0.1 -uroot -proot -P3306' notice that
as input is given to the command, tty option is not provided to docker exec

## 7. bin/gitIsAncestorOf

**Help**

```text
@@@gitIsAncestorOf_help@@@
```

## 8. bin/mysql2puml

**Help**

```text
@@@mysql2puml_help@@@
```

Mysql dump of some tables

```bash
mysqldump --skip-add-drop-table --skip-add-locks --skip-disable-keys --skip-set-charset \
  --host=127.0.0.1 --port=3345 --user=root --password=root --no-data skills \
  $(mysql --host=127.0.0.1 --port=3345 --user=root --password=root skills \
    -Bse "show tables like 'core\_%'") \
  | grep -v '^\/\*![0-9]\{5\}.*\/;$' > doc/schema.sql
```

Transform mysql dump to plant uml format

```bash
mysql2puml tests/tools/data/mysql2puml.dump.sql -s default > tests/tools/data/mysql2puml.puml
```

Plantuml diagram generated

```plantuml
@@@mysql2puml_plantuml_diagram@@@
```

using plantuml software, here an example of resulting diagram

![resulting database diagram](tests/data/mysql2puml-model.png)
