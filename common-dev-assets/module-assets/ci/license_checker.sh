#!/usr/bin/env bash

# Pre-commit hook that checks if the license exists in the project with terraform files

# exit 0 if internal repo
if git remote -v | head -n 1 | grep -q "github.ibm"; then
  exit 0
fi

# ensure LICENSE file exists if .tf file is detected in root directory
count=$(find ./*.tf 2>/dev/null | wc -l | xargs)
if [ "$count" != 0 ]; then
  if [[ ! -f "LICENSE" ]]; then
    echo "Required LICENSE file is missing. Please add it and try again."
    exit 1
  fi
fi
