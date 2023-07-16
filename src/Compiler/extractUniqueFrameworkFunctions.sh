#!/usr/bin/env bash

# from src file extract all the framework functions
# one function by line
# unique and sorted list
# Note that function names being part of comments
# or strings are not removed from the final list
Compiler::extractUniqueFrameworkFunctions() {
  local file="$1"
  Filters::bashCommentLines "${file}" |
    Filters::bashFrameworkFunctions |
    awk '{$1=$1};1' |
    sort |
    uniq
}
