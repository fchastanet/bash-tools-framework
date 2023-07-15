#!/usr/bin/env bash

Filters::removeExternalQuotes() {
  sed -E $'s/^[\"\'](.+)[\"\']$/\\1/g'
}
