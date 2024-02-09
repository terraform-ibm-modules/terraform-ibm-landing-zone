#!/bin/bash
set -e

# Validate that required environment variables are set
if [ -z "$TF_VAR_ibmcloud_api_key" ]
then
      echo "ERROR: Environment variable TF_VAR_ibmcloud_api_key must be set"
      exit 1
fi

if [ -z "$PROFILE_ID" ]
then
      echo "ERROR: Environment variable PROFILE_ID must be set"
      exit 1
fi

if [ -z "$SCC_INSTANCE_ID" ]
then
      echo "ERROR: Environment variable SCC_INSTANCE_ID must be set"
      exit 1
fi

if [ -z "$SCC_REGION" ]
then
      echo "ERROR: Environment variable SCC_REGION must be set"
      exit 1
fi

# Change to target directory if provided as an argument
if [ $# -eq 1 ]
then
    echo "Changing to target directory"
    cd "$1" || { echo "Directory $1 does not exist. Exiting..."; exit 1; }
fi

if [ -z "$TOOLCHAIN_ID" ]
then
  echo "ERROR: Environment variable TOOLCHAIN_ID must be set"
  exit 1
fi

if [ -z "$CRA_IGNORE_RULES_FILE" ]
then
  CRA_IGNORE_RULES_FILE="cra-tf-validate-ignore-rules.json"
fi

# Initialize variables used in the script
ignoring_rules="[]"
number_of_ignored_rules=0
number_of_skipped_evidences=0
number_of_scanned_evidences=0
number_of_resourced_failed_rules=0
report_json="report.json"
skipped_json="skipped.json"
ignored_json="ignored.json"
relevant_rules_json="relevant_rules.json"
failed_json="failed.json"
plan_out="plan.out"
plan_json="plan.json"
profile_json="profile.json"

# Get IAM token for authentication
echo "Getting IAM token..."
IAM_TOKEN=$(curl -s -X POST "https://iam.cloud.ibm.com/identity/token" -H "Content-Type: application/x-www-form-urlencoded" -H "Accept: application/json" --data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" --data-urlencode "apikey=$TF_VAR_ibmcloud_api_key" | jq -r '.access_token')

# Fetch the profile JSON using curl
echo "Getting Policy JSON for ID: $PROFILE_ID"
curl -s --retry 3 -X GET "https://$SCC_REGION.compliance.cloud.ibm.com/instances/$SCC_INSTANCE_ID/v3/profiles/$PROFILE_ID" -H "Authorization: Bearer $IAM_TOKEN" -H "Content-Type: application/json" -o "$profile_json"

# Initialize Terraform and run Terraform plan
terraform init
terraform plan --out "$plan_out"

# Convert Terraform plan output to JSON format
terraform show -json "$plan_out" | jq '.' > "$plan_json"

# Login to IBM Cloud using API key and set the target region
ibmcloud login --apikey "${TF_VAR_ibmcloud_api_key}" -r "$SCC_REGION"

# Run IBM Cloud CRA Terraform validate and continue if it fails, Will fail later if any ot the failures are valid ie not on the ignore list or apply to the created Terraform resources
set +e
ibmcloud cra terraform-validate \
      --tf-plan "$plan_json" \
      --report "$report_json" \
      --toolchainid "$TOOLCHAIN_ID" \
      --strict \
      --policy-file "$profile_json" >&2
exit_status=$?

# --strict flag results in exit status 2 if policies fail.
# Any other non-zero exit code should hard fail the script
# (fix for https://github.ibm.com/GoldenEye/issues/issues/4977)
if [ ${exit_status} -ne 2 ] && [ ${exit_status} -ne 0 ]; then
  echo "Encountered an error while attempting to run CRA. Exiting."
  exit 1
fi
set -e
# Fail pipeline if any other step fails

# Check if the CRA_IGNORE_RULES_FILE exists and read the ignore rules from it
if [ -f "$CRA_IGNORE_RULES_FILE" ]; then
  # built ignore list from file
  ignoring_rules=$(jq '.scc_rules[] | .scc_rule_id ' "$CRA_IGNORE_RULES_FILE" | jq -c -s '.')
  echo "From CRA rules ignore file: ${CRA_IGNORE_RULES_FILE}"
  echo "Ignore rules: ${ignoring_rules}"
else
  echo "CRA rules Ignore file not found: ${CRA_IGNORE_RULES_FILE}"
fi

# skipped evidences are stored in $WORKSPACE/$output-filtered-out-evidences and consist of
# evidence not related to a resource definition found or evidence corresponding to an ignored rule
jq --argjson ignoring_rules "$ignoring_rules" '.evidence_list[] | select(((.found_in_v2 | length) == 0) or (."rule-Id" as $ruleid | $ignoring_rules | index($ruleid)))' "$report_json" | \
  jq -s '{evidence_list:.}' > "$skipped_json"
number_of_skipped_evidences=$(jq -r '.evidence_list | length' "$skipped_json")
echo "$number_of_skipped_evidences skipped SCC Rules"

# selected evidences are stored in report-selected-evidences
jq --argjson ignoring_rules "$ignoring_rules" '.evidence_list[] | select(((.found_in_v2 | length) > 0) and (."rule-Id" as $ruleid | $ignoring_rules | index($ruleid) | not))' "$report_json" | \
  jq -s '{evidence_list:.}' > "$relevant_rules_json"

number_of_scanned_evidences=$(jq -r '.evidence_list | length' "$relevant_rules_json")
echo "$number_of_scanned_evidences Relevant SCC Rules"

number_of_ignored_rules=$(echo "$ignoring_rules" | jq -r '. | length')
# only prompt ignoring rules if the get_env cra_tf_ignore_rules was not returning empty
if [[ "$number_of_ignored_rules" != 0 ]]; then
  echo "List of SCC Rule identifier to ignore as per configuration is $ignoring_rules"
  jq --argjson ignoring_rules "$ignoring_rules" '.evidence_list[] | select(((.found_in_v2 | length) > 0) and (."rule-Id" as $ruleid | $ignoring_rules | index($ruleid)))' "$report_json" | jq -s '{evidence_list:.}' > "$ignored_json"
  if [[ "$number_of_ignored_rules" != 0 ]]; then
    echo "$number_of_ignored_rules ignored SCC rules reported & found in Terraform resource(s):"
    jq -r '.evidence_list[] | "Rule ID \(.["rule-Id"]) : \(.text)\n\tFound in:\n\t\t\(.found_in_v2[] | "resource_address:\(.resource_address)")"' "$ignored_json"
    echo "--------------------------------------------------"
  fi
fi

# failed evidences
jq '.evidence_list[] | select(.result=="failed")' "$relevant_rules_json" | jq -s '{evidence_list:.}' > "$failed_json"
number_of_resourced_failed_rules=$(jq -r '.evidence_list | length' "$failed_json")
if [[ "$number_of_resourced_failed_rules" == 0 ]]; then
  echo "No failed SCC rules reported & found in Terraform resource(s)"
  echo "--------------------------------------------------"
  exit_code=0
else
  echo "$number_of_resourced_failed_rules failed SCC Rules reported & found in Terraform resource(s):"
  jq -r '.evidence_list[] | "Rule ID \(.["rule-Id"]) : \(.text)\n\tFound in:\n\t\t\(.found_in_v2[] | "resource_address:\(.resource_address)")"' "$failed_json"
  echo "--------------------------------------------------"
  exit_code=1
fi
echo "--------------------------------------------------"
echo "SUMMARY:"
echo "$number_of_skipped_evidences Skipped SCC Rules (Including Ignored)"
echo "$number_of_ignored_rules Ignored SCC Rules"
echo "$number_of_scanned_evidences Relevant SCC Rules (After Ignore)"
echo "$number_of_resourced_failed_rules Failed SCC Rules"
echo "--------------------------------------------------"

# Exit with the appropriate exit code based on the presence of failed rules
exit $exit_code
