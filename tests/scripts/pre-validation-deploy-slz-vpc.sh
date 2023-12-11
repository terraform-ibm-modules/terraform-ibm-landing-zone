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
  cwd=$(pwd)
  cd ${TERRAFORM_SOURCE_DIR}
  echo "Provisioning prerequisite SLZ VPC .."
  terraform init || exit 1
  # $VALIDATION_APIKEY is available in the catalog runtime
  {
    echo "ibmcloud_api_key=\"${VALIDATION_APIKEY}\""
    echo "prefix=\"slz-$(openssl rand -hex 2)\""
    echo "region=\"${REGION}\""
  } >> ${TF_VARS_FILE}
  terraform apply -input=false -auto-approve -var-file=${TF_VARS_FILE} || exit 1
  cd "${cwd}"

  # Generate SSH keys and place in temp directory
  temp_dir=$(mktemp -d)
  ssh-keygen -f "${temp_dir}/id_rsa" -t rsa -N '' <<<y

  # Extract public key value and delete temp directory
  ssh_public_key=$(cat "${temp_dir}/id_rsa.pub")
  rm -rf "${temp_dir}"

  # append prefix, vpc_id, boot_volume_encryption_key, region and ssh_public_key to json
  prefix_var_name="prefix"
  prefix_value=$(terraform output -state=terraform.tfstate -raw prefix)
  vpc_id_var_name="vpc_id"
  vpc_id_value=$(terraform output -state=terraform.tfstate -raw management_vpc_id)
  kms_key_var_name="boot_volume_encryption_key"
  kms_key_value=$(terraform output -state=terraform.tfstate -raw vsi_kms_key_crn)
  region_var_name="region"
  region_value="${REGION}"
  ssh_public_key_var_name="ssh_public_key"
  ssh_public_key_value="${ssh_public_key}"
  echo "Appending '${prefix_var_name}', '${vpc_id_var_name}', '${kms_key_var_name}', '${region_var_name}' and '${ssh_public_key_var_name}' input variable values to ${JSON_FILE}.."

  jq -r --arg prefix_var_name "${prefix_var_name}" \
        --arg prefix_value "${prefix_value}" \
        --arg vpc_id_var_name "${vpc_id_var_name}" \
        --arg vpc_id_value "${vpc_id_value}" \
        --arg kms_key_var_name "${kms_key_var_name}" \
        --arg kms_key_value "${kms_key_value}" \
        --arg region_var_name "${region_var_name}" \
        --arg region_value "${region_value}" \
        --arg ssh_public_key_var_name "${ssh_public_key_var_name}" \
        --arg ssh_public_key_value "${ssh_public_key_value}" \
        '. + {($prefix_var_name): $prefix_value, ($vpc_id_var_name): $vpc_id_value, ($kms_key_var_name): $kms_key_value, ($region_var_name): $region_value}, ($ssh_public_key_var_name): $ssh_public_key_value}' "${JSON_FILE}" > tmpfile && mv tmpfile "${JSON_FILE}" || exit 1

  echo "Pre-validation complete successfully"
)
