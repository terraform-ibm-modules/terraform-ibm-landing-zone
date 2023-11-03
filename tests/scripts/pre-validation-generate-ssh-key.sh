#! /bin/bash

set -e

if [ $# -eq 0 ]; then
  echo "No arguments supplied - var_name and dir need to be passed as args (in that order)"
  exit 1
fi

var_name=$1
dir=$2

# Paths relative to the root directory
TERRAFORM_SOURCE_DIR="tests/resources"
JSON_FILE="${dir}/catalogValidationValues.json"  # This gets created by pipeline code based on the catalogValidationValues.json.template

(
  cd ${TERRAFORM_SOURCE_DIR}
  terraform init || exit 1
  terraform apply -auto-approve || exit 1

  ssh_public_key=$(terraform output -state=terraform.tfstate -raw ssh_public_key)
  echo "Appending SSH public key to ${JSON_FILE}.."
  jq -r --arg var_name "${var_name}" --arg ssh_public_key "${ssh_public_key}" '. + {($var_name): $ssh_public_key}' "${JSON_FILE}" > tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
