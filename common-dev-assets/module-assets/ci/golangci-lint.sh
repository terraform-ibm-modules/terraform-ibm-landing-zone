#!/bin/bash
set -e

NUM_GO_FILES=$(find . -maxdepth 1 -name 'tests/*.go' | wc -l)

if [ "${NUM_GO_FILES}" -gt 0 ]; then
  # Ensure go.mod and go.sum files exist before attempting to run golangci-lint
  for f in go.mod go.sum; do
    if [ ! -f "tests/$f" ]; then
      echo -e "ERROR: Did not find ${f} in the tests directory.\n\nMake sure to run:\ngo mod init <MODULE>\ngo mod tidy"
      exit 1
    fi
  done

  # golangci-lint must run in same directory as go.mod
  cd tests
  golangci-lint run --fix --timeout=5m
  cd ..
else
  echo "Found no go files in the tests directory - skipping linting checks"
fi
