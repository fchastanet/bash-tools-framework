#!/usr/bin/env bash

Filters::camel2snakeCase() {
  # reused regexp from https://askubuntu.com/a/1203160/1364259 transformed to posix
  sed -E 's/([A-Z]+)/_\1/g;s/^_//g;s#-#_#g;s#([0-9]+)_#\1#g;s#([^A-Za-z0-9])_#\1#g' | Filters::toLowerCase
}
