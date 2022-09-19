#! /bin/bash

set -e

TERRAFORM_SOURCE_DIR="terraform-ibm-landing-zone/tests/resources"
JSON_FILE="catalogValidationValues.json"

echo "Generating SSH public key to be used for validation.."

(
  cd ${TERRAFORM_SOURCE_DIR}
  terraform init
  terraform apply -auto-approve
)

ssh_public_key=$(terraform output -state=${TERRAFORM_SOURCE_DIR}/terraform.tfstate -json ssh_public_key)

echo "Appending SSH public key to ${JSON_FILE}.."
jq -r --arg ssh_public_key "${ssh_public_key}" '. + {ssh_public_key: $ssh_public_key}' "${JSON_FILE}" > tmpfile && mv tmpfile "${JSON_FILE}"

echo "Pre-validation complete"
