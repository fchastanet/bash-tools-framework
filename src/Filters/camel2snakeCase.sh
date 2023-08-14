#!/usr/bin/env bash

# @description transform camel case format to snake case
# @example text
#   TEST => test
#   camelCase2SnakeCase => camel_case2snake_case
#   origin/featureTest/Tools-1456 => origin/feature_test/tools_1456
#   # the function is clever enough with some strange case (not really camel case)
#   featureTEST/TOOLS-1456 => feature_test/tools_1456
#   innovation/vuecli-with-web => innovation/vuecli_with_web
# @stdin the string to filter
# @stdout the string converted to snake case
Filters::camel2snakeCase() {
  # reused regexp from https://askubuntu.com/a/1203160/1364259 transformed to posix
  sed -E 's/([A-Z]+)/_\1/g;s/^_//g;s#-#_#g;s#([0-9]+)_#\1#g;s#([^A-Za-z0-9])_#\1#g' | Filters::toLowerCase
}
