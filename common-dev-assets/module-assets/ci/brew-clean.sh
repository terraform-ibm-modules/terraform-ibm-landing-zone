#!/bin/bash

set -o errexit
set -o pipefail
set -o nounset
#set -o xtrace

TO_REMOVE=( pre-commit terraform-docs tflint tfsec golangci-lint shellcheck hadolint )

for p in "${TO_REMOVE[@]}"; do
  if brew list "${p}" &>/dev/null; then
    echo -n "Do you wish to brew uninstall ${p} (y/n)? "
    old_stty_cfg=$(stty -g)
    stty raw -echo
    answer=$( while ! head -c 1 | grep -i '[ny]' ;do true ;done )
    stty "${old_stty_cfg}"
    if echo "${answer}" | grep -iq "^y" ;then
      echo Yes
      brew uninstall "${p}"
    else
      echo No
    fi
  fi
done

echo "Brew cleanup complete"
