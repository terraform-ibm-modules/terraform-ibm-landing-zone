#! /bin/bash

set -e

if [ $# -eq 0 ]; then
  echo "No arguments supplied - expected the terraform input variable name for ssh public key"
  exit 1
fi

var_name=$1

# Paths relative to base directory of script
BASE_DIR=$(dirname "$0")
TERRAFORM_SOURCE_DIR="../resources"
JSON_FILE="../../../catalogValidationValues.json"

(
  # Execute script from base directory
  cd "${BASE_DIR}"
  echo "Generating SSH public key to be used for validation .."

  cd ${TERRAFORM_SOURCE_DIR}
  terraform init || exit 1
  terraform apply -auto-approve || exit 1

  ssh_public_key=$(terraform output -state=terraform.tfstate -raw ssh_public_key)
  echo "Appending SSH public key to $(basename ${JSON_FILE}).."
  jq -r --arg var_name "${var_name}" --arg ssh_public_key "${ssh_public_key}" '. + {($var_name): $ssh_public_key}' "${JSON_FILE}" > tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
