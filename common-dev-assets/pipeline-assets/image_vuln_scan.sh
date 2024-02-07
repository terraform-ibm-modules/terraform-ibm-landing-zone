#!/bin/bash
# For use within Tekton pipeline

USAGE="
Usage: $0 <registry> <namespace> <image> <version> <apikey> <ignore-config-issues>

where:

- <registry> is the ibm container registry DNS name (e.g. us.icr.io)
- <namespace> is the container registry namespace to upload the image to
- <image> is the name of the docker image to scan
- <version> is the docker image tag
- <apikey> is the api key with permissions to push to the container registry
- <ignore-config-issues> is a boolean (true or false) whether to ignore configuration issues or not

Dependencies:
- jq
"

check_for_jq() {
    if ! hash jq 2>/dev/null; then
        echo "Could not find jq installed. Please install and try again"
        exit 1
    fi
}

retry() {
  local retries=$1
  shift

  local count=0
  until "$@"; do
    exit=$?
    wait=$((2 ** count))
    count=$((count + 1))
    if [ $count -lt "$retries" ]; then
      echo "Retry $count/$retries exited $exit, retrying in $wait seconds..."
      sleep $wait
    else
      echo "Retry $count/$retries exited $exit, no more retries left."
      return $exit
    fi
  done
  echo "LOCAL REPORT: ${LOCAL_REPORT}"
  return 0
}

get_bearer_token() {
    if [ "$#" -ne 1 ]; then
      echo "Usage: get_bearer_token <apikey>"
      exit 1
    fi
    APIKEY=$1

    bearer=$(curl -ks -X POST \
-H "Content-Type: application/x-www-form-urlencoded" \
-H "Accept: application/json" \
--data-urlencode "grant_type=urn:ibm:params:oauth:grant-type:apikey" \
--data-urlencode "apikey=$APIKEY" \
"${IAM_API_URL}" \
| jq -r .access_token)

   echo "Bearer $bearer"
}

check_vulnerability_scan() {
    if [ "$#" -ne 4 ]; then
      echo "Usage: $0 <image> <version> <token> <ignore-config>"
      exit 1
    fi
    IMAGE=$1
    VERSION=$2
    TOKEN=$3
    IGNORE_CONFIG=$4
    CLOUD_VA_REPORT_URL=${CLOUD_VA_REPORT_URL/<image>/$IMAGE}
    CLOUD_VA_REPORT_URL=${CLOUD_VA_REPORT_URL/<version>/$VERSION}
    local response
    local status
    response=$(curl -Lks -H "Authorization: $TOKEN" "${CONTAINER_REGISTRY_URL}${VA_IMAGE_REPORT_API_ENDPOINT}${CONTAINER_REGISTRY}/${IMAGE}:${VERSION}")
    echo "${response}" > "${LOCAL_REPORT}"
    status=$(echo "$response" | jq -r .status)
    message=$(echo "$response" | jq -r .message)
    vulnerabilities_number=$(echo "$response" | jq -r '.vulnerabilities | length' )
    configuration_issues_number=$(echo "$response" | jq -r '.configuration_issues | length' )
    echo "FAIL" > "${RESULT_FILE}"
    if [ "$status" != 'null' ]; then
        echo 'Image processed'
        if [ "$vulnerabilities_number" -lt 1 ]; then
            detected_vul=false
            echo 'No Vulnerabilities found!'
        else
            detected_vul=true
            echo 'Vulnerabilities found!'
            echo "$response" | jq -r .vulnerabilities
        fi
        if [ "$configuration_issues_number" -lt 1 ]; then
            detected_config_issue=false
            echo 'No configuration issues found!'
        else
            detected_config_issue=true
            echo 'Configuration issues found!'
            echo "$response" | jq -r .configuration_issues
            if [ "${IGNORE_CONFIG}" = true ]; then
              echo "Ignoring configuration issues"
            fi
        fi

        if [ "${IGNORE_CONFIG}" != true ]; then
          if [ ${detected_vul} = false ] && [ ${detected_config_issue} = false ]; then
              echo "PASS" > "${RESULT_FILE}"
          fi
        else
          if [ ${detected_vul} = false ]; then
              echo "PASS" > "${RESULT_FILE}"
          fi
        fi

        echo "IBM CLOUD REPORT: ${CLOUD_VA_REPORT_URL}"
        return 0
    else
        echo 'Image not scanned yet'
        if [ "$message" != 'null' ]; then
            echo "$message"
            if [[ "$message" == *"does not exist in this namespace"* || "$message" == *"The identity provided is not authorized to perform the requested action"* || "$message" == *"Your account is not authorized to view"* ]]; then
                exit 1
            fi
        fi
        return 1
    fi
}

if [ "$#" -ne 6 ]; then
  echo "${USAGE}"
  exit 1
fi

check_for_jq

REGISTRY_DNS_NAME=$1
NAMESPACE=$2
IMAGE=$3
VERSION=$4
APIKEY=$5
IGNORE_CONFIG_ISSUES=$6
IAM_API_URL='https://iam.cloud.ibm.com/identity/token'
CONTAINER_REGISTRY_URL="https://${REGISTRY_DNS_NAME}/"
VA_IMAGE_REPORT_API_ENDPOINT='va/api/v4/report/image/'
CONTAINER_REGISTRY="${REGISTRY_DNS_NAME}/${NAMESPACE}"
CLOUD_VA_REPORT_URL="https://cloud.ibm.com/containers-kubernetes/registry/images/${NAMESPACE}/<image>/<version>/detail/issues?region=ibm:yp:us-south"
LOCAL_REPORT="/tmp/${IMAGE}-va-report.json"
token=$(get_bearer_token "$APIKEY")
TMP_DIR=$(mktemp -d /tmp/ci-XXXXXXXXXX)
RESULT_FILE="${TMP_DIR}/result.txt"
RESULT=$(retry 20 check_vulnerability_scan "$IMAGE" "$VERSION" "$token" "$IGNORE_CONFIG_ISSUES")

echo "${RESULT}"

if [ "$(cat "${RESULT_FILE}")" != "PASS" ]; then
  exit 1
fi
