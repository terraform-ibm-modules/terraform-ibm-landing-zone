#!/bin/bash
set -e

ignoring_goals="[]"
number_of_ignored_goals=0
number_of_skipped_evidences=0
number_of_scanned_evidences=0
number_of_resourced_failed_goals=0
report_json="report.json"
skipped_json="skipped.json"
ignored_json="ignored.json"
relevant_goals_json="relevant_goals.json"
failed_json="failed.json"
plan_out="plan.out"
plan_json="plan.json"

if [ -z "$TF_VAR_ibmcloud_api_key" ]
then
      echo "ERROR: Environment variable TF_VAR_ibmcloud_api_key must be set"
      exit 1
fi

if [ $# -eq 1 ]
then
    echo "Changing to target directory"
    cd "$1" || { echo "Directory $1 does not exits. Exiting..."; exit 1; }
fi

if [ -z "$REGION" ]
then
      REGION="us-south"
fi

if [ -z "$TOOLCHAIN_ID" ]
then
  echo "ERROR: Environment variable TOOLCHAIN_ID must be set"
  exit 1
fi

if [ -z "$CRA_IGNORE_GOALS_FILE" ]
then
  CRA_IGNORE_GOALS_FILE="cra-tf-validate-ignore-goals.json"
fi

terraform init
terraform plan --out "$plan_out"
# Obtain JSON multilines (hence jq)
terraform show -json "$plan_out" | jq '.' > "$plan_json"
ibmcloud login --apikey "${TF_VAR_ibmcloud_api_key}" -r "$REGION"
# Continue if CRA Fails, Will fail later if any ot the failures are valid ie not on the ignore list or apply to the created Terraform resources
set +e
ibmcloud cra terraform-validate \
      --tf-plan "$plan_json" \
      --report "$report_json" \
      --toolchainid "$TOOLCHAIN_ID" \
      --strict >&2
set -e
# Fail pipeline if any other step fails

if [ -f "$CRA_IGNORE_GOALS_FILE" ]; then
  # built ignore list from file
  ignoring_goals=$(jq '.scc_goals[] | .scc_goal_id ' "$CRA_IGNORE_GOALS_FILE" | jq -c -s '.')
  echo "From CRA goals ignore file: ${CRA_IGNORE_GOALS_FILE}"
  echo "Ignore goals: ${ignoring_goals}"
else
  echo "CRA goals Ignore file not found: ${CRA_IGNORE_GOALS_FILE}"
fi

echo "Keeping only the SCC goals results because found in Terraform resource(s) - others are considered as skipped"
echo "--------------------------------------------------"
# skipped evidences are stored in $WORKSPACE/$output-filtered-out-evidences and consist of
# evidence not related to a resource definition found or evidence corresponding to an ignored goal
jq --argjson ignoring_goals "$ignoring_goals" '.evidence_list[] | select(((.found_in_v2 | length) == 0) or (."goal-Id" as $goalid | $ignoring_goals | index($goalid)))' "$report_json" | \
  jq -s '{evidence_list:.}' > "$skipped_json"
number_of_skipped_evidences=$(jq -r '.evidence_list | length' "$skipped_json")
echo "$number_of_skipped_evidences skipped SCC Goals"

# selected evidences are stored in report-selected-evidences
jq --argjson ignoring_goals "$ignoring_goals" '.evidence_list[] | select(((.found_in_v2 | length) > 0) and (."goal-Id" as $goalid | $ignoring_goals | index($goalid) | not))' "$report_json" | \
  jq -s '{evidence_list:.}' > "$relevant_goals_json"

number_of_scanned_evidences=$(jq -r '.evidence_list | length' "$relevant_goals_json")
echo "$number_of_scanned_evidences Relevant SCC Goals"

number_of_ignored_goals=$(echo "$ignoring_goals" | jq -r '. | length')
# only prompt ignoring goals if the get_env cra_tf_ignore_goals was not returning empty
if [[ "$number_of_ignored_goals" != 0 ]]; then
  echo "List of SCC Goal identifier to ignore as per configuration is $ignoring_goals"
  jq --argjson ignoring_goals "$ignoring_goals" '.evidence_list[] | select(((.found_in_v2 | length) > 0) and (."goal-Id" as $goalid | $ignoring_goals | index($goalid)))' "$report_json" | jq -s '{evidence_list:.}' > "$ignored_json"
  if [[ "$number_of_ignored_goals" != 0 ]]; then
    echo "$number_of_ignored_goals ignored SCC goals reported & found in Terraform resource(s):"
    jq -r '.evidence_list[] | "Goal ID \(.["goal-Id"]) : \(.text)\n\tFound in:\n\t\t\(.found_in_v2[] | "resource_address:\(.resource_address)")"' "$ignored_json"
    echo "--------------------------------------------------"
  fi
fi


# failed evidences
jq '.evidence_list[] | select(.result=="failed")' "$relevant_goals_json" | jq -s '{evidence_list:.}' > "$failed_json"
number_of_resourced_failed_goals=$(jq -r '.evidence_list | length' "$failed_json")
if [[ "$number_of_resourced_failed_goals" == 0 ]]; then
  echo "No failed SCC goals reported & found in Terraform resource(s)"
  echo "--------------------------------------------------"
  exit_code=0
else
  echo "$number_of_resourced_failed_goals failed SCC Goals reported & found in Terraform resource(s):"
  jq -r '.evidence_list[] | "Goal ID \(.["goal-Id"]) : \(.text)\n\tFound in:\n\t\t\(.found_in_v2[] | "resource_address:\(.resource_address)")"' "$failed_json"
  echo "--------------------------------------------------"
  exit_code=1
fi
echo "--------------------------------------------------"
echo "SUMMARY:"
echo "$number_of_skipped_evidences Skipped SCC Goals (Including Ignored)"
echo "$number_of_ignored_goals Ignored SCC Goals"
echo "$number_of_scanned_evidences Relevant SCC Goals (After Ignore)"
echo "$number_of_resourced_failed_goals Failed SCC Goals"
echo "--------------------------------------------------"
exit $exit_code
