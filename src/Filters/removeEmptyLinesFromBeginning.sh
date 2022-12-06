#!/usr/bin/env bash

Filters::removeEmptyLinesFromBeginning() {
  awk 'NF {p=1} p'
}
