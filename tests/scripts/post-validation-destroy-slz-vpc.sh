#! /bin/bash

########################################################################################################################
## This script is used by the catalog pipeline to destroy the SLZ VPC, which was provisioned as a prerequisite        ##
## for the existing VPC VSI extension DA                                                                              ##
########################################################################################################################

set -e

TERRAFORM_SOURCE_DIR="tests/resources/slz-vpc"
TF_VARS_FILE="terraform.tfvars"

(
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Destroying prerequisite SLZ VPC .."
  terraform destroy -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  echo "Post-validation complete successfully"
)
