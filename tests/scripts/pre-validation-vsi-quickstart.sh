#! /bin/bash

set -e

script_dir=$(dirname "$0")
"./${script_dir}/pre-validation-generate-ssh-key.sh" "ssh_key" "patterns/vsi-quickstart"
