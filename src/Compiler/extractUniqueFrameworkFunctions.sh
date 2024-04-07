#!/usr/bin/env bash

# @description from src file extract all the framework functions
# one function by line, unique and sorted list
# @warning Note that function names being part of comments or strings are not removed from the final list
# @arg $1 file:String
# @stdout list of bash framework functions used by given file
Compiler::extractUniqueFrameworkFunctions() {
  local file="$1"
  Filters::commentLines "${file}" |
    Filters::bashFrameworkFunctions |
    Filters::uniqUnsorted
}
