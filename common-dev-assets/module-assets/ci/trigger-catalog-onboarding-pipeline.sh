#! /bin/bash

set -e

PRG=$(basename -- "${0}")

USAGE="
usage:	${PRG}
        [--help]

        Required environment variables:
        CATALOG_TEKTON_WEBHOOK_URL
        CATALOG_TEKTON_WEBHOOK_TOKEN

        Optional environment variables:
        CATALOG_PUBLISH_APIKEY  (Set to publish to an external account catalog - if not specified, will use GoldenEye Ops account)
        CATALOG_VALIDATION_APIKEY  (Set to validate in an external account catalog - if not specified, will use GoldenEye Dev account)

        Optional arguments:
        [--version=<version>]  (If not specified, the latest GIT release version will be used)
        [--github_url=<github_url>]  (Defaults to github.com)
        [--github_org=<github-org>]  (Defaults to terraform-ibm-modules)
"

# Verify required environment variables are set
all_exist=true
env_var_array=( CATALOG_TEKTON_WEBHOOK_URL CATALOG_TEKTON_WEBHOOK_TOKEN )
# set +u
for var in "${env_var_array[@]}"; do
  [ -z "${!var}" ] && echo "$var not defined." && all_exist=false
done
# set -u
if [ $all_exist == false ]; then
  echo "One or more required environment variables are not defined. Exiting."
  exit 1
fi

# Pre-set macros so nounset doesn't complain
VERSION=""
GITHUB_URL="github.com"
GITHUB_ORG="terraform-ibm-modules"
PIPELINE_YAML=".catalog-onboard-pipeline.yaml"
EXTERNAL_CATALOG=false
EXTERNAL_VALIDATION=false

if [ -n "${CATALOG_PUBLISH_APIKEY}" ]; then
  EXTERNAL_CATALOG=true
fi
if [ -n "${CATALOG_VALIDATION_APIKEY}" ]; then
  EXTERNAL_VALIDATION=true
fi

# Verify ibm_catalog.json exists
if ! test -f "${PIPELINE_YAML}"; then
  echo "No ${PIPELINE_YAML} file was detected, unable to proceed."
  exit 1
fi

# Determine repo name
REPO_NAME="$(basename "$(git config --get remote.origin.url)")"
REPO_NAME="${REPO_NAME//.git/}"

# Loop through all args
for arg in "$@"; do
  set +e
  found_match=false
  if echo "${arg}" | grep -q -e --version=; then
    VERSION=$(echo "${arg}" | awk -F= '{ print $2 }')
    found_match=true
  fi
  if echo "${arg}" | grep -q -e --github_url=; then
    GITHUB_URL=$(echo "${arg}" | awk -F= '{ print $2 }')
    found_match=true
  fi
  if echo "${arg}" | grep -q -e --github_org=; then
    GITHUB_ORG=$(echo "${arg}" | awk -F= '{ print $2 }')
    found_match=true
  fi
  if [ ${found_match} = false ]; then
    if [ "${arg}" != --help ]; then
      echo "Unknown command line argument:  ${arg}"
    fi
    echo "${USAGE}"
    exit 1
  fi
  set -e
done

# Add all offerings into offerings array
offerings_array=()
while IFS='' read -r line; do offerings_array+=("$line"); done < <(yq -r '.offerings | .[].name' "${PIPELINE_YAML}")

# Loop through all offerings and trigger pipeline
for offering in "${offerings_array[@]}"; do

    # Generate payload
    payload=$(jq -c -n --arg repoName "${REPO_NAME}" \
                    --arg gitUrl "${GITHUB_URL}" \
                    --arg gitOrg "${GITHUB_ORG}" \
                    --arg offering "${offering}" \
                    '{"repo-name":$repoName,
                        "git-url":$gitUrl,
                        "git-org": $gitOrg,
                        "offering-name": $offering
                        }')
    if [ -n "${VERSION}" ]; then
      version=$(jq -c -n --arg version "${VERSION}" '{"version": $version}')
      payload=$(echo "${payload} ${version}" | jq -c -s add)
    fi
    if [ ${EXTERNAL_CATALOG} = true ] || [ ${EXTERNAL_VALIDATION} = true ]; then
      properties='[]'
      if [ ${EXTERNAL_CATALOG} = true ]; then
        publish_apikey=$(jq -c -n --arg apikey "${CATALOG_PUBLISH_APIKEY}" '[{"name":"catalog-api-key","type":"SECURE","value":$apikey}]')
        properties=$(echo "${properties} ${publish_apikey}" | jq -c -s add)
      fi
      if [ ${EXTERNAL_VALIDATION} = true ]; then
        validation_apikey=$(jq -c -n --arg apikey "${CATALOG_VALIDATION_APIKEY}" '[{"name":"validation-api-key","type":"SECURE","value":$apikey}]')
        properties=$(echo "${properties} ${validation_apikey}" | jq -c -s add)
      fi
      properties_object=$(jq -c -n --argjson properties "${properties}" '{"properties":$properties}')
      payload=$(echo "${payload} ${properties_object}" | jq -c -s add)
    fi

    # Trigger pipeline
    echo
    echo "Kicking off tekton pipeline for ${offering} .."
    curl -fLsS -X POST \
      "$CATALOG_TEKTON_WEBHOOK_URL" \
      -H "Content-Type: application/json" \
      -H "token: ${CATALOG_TEKTON_WEBHOOK_TOKEN}" \
      -d "${payload}"
    echo
done
