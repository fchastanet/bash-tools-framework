#!/usr/bin/env bash
set -euo pipefail

echo "Installing vendors..."
./bin/installRequirements

echo "Checking if documentation is up to date..."
./bin/doc --ci
