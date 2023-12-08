#! /bin/bash

########################################################################################################################
## This script is used by the catalog pipeline to deploy SLZ VPC, which is a prerequisite for the existing VPC VSI DA ##
## extension                                                                                                          ##
########################################################################################################################

set -e

DA_DIR="patterns/vsi-extension"
TERRAFORM_SOURCE_DIR="tests/resources/slz-vpc"
JSON_FILE="${DA_DIR}/catalogValidationValues.json"
REGION="au-syd"
TF_VARS_FILE="terraform.tfvars"

(
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Provisioning prerequisite SLZ VPC .."
  terraform init || exit 1
  # $VALIDATION_APIKEY is available in the catalog runtime
  {
    echo "ibmcloud_api_key=\"${VALIDATION_APIKEY}\""
    echo "prefix=\"slz-$(openssl rand -hex 2)\""
    echo "region=\"${REGION}\""
    echo "enable_transit_gateway=false"
    echo "add_atracker_route=false"
  } >> ${TF_VARS_FILE}
  terraform apply -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1

  # append public sshkey to json
  ./pre-validation-generate-ssh-key.sh ssh_public_key ${DA_DIR}

  # append prefix, vpc_id and boot_volume_encryption_key to json
  prefix_var_name="prefix"
  prefix_value=$(terraform output -state=terraform.tfstate -raw prefix)
  vpc_id_var_name="vpc_id"
  vpc_id_value=$(terraform output -state=terraform.tfstate -raw management_vpc_id)
  kms_key_var_name="boot_volume_encryption_key"
  kms_key_value=$(terraform output -state=terraform.tfstate -raw vsi_kms_key_crn)
  region_var_name="region"
  region_value="${REGION}"
  echo "Appending '${prefix_var_name}', '${vpc_id_var_name}', and '${kms_key_var_name}' input variable values to ${JSON_FILE}.."
  jq -r --arg prefix_var_name "${prefix_var_name}" \
        --arg prefix_value "${prefix_value}" \
        --arg vpc_id_var_name "${vpc_id_var_name}" \
        --arg vpc_id_value "${vpc_id_value}" \
        --arg kms_key_var_name "${kms_key_var_name}" \
        --arg kms_key_value "${kms_key_value}" \
        --arg region_var_name "${region_var_name}" \
        --arg region_value "${region_value}" \
        '. + {($prefix_var_name): $prefix_value, ($vpc_id_var_name): $vpc_id_value, ($kms_key_var_name): $kms_key_value}, ($region_var_name): $region_value}' "${JSON_FILE}" > tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
