#!/usr/bin/env bash
# For use within Tekton pipeline

set -e

# shellcheck disable=SC2155
export IBMCLOUD_APIKEY="$(get_env ibmcloud-api-key)"

if [ -z "$1" ];then
  EXTRA_TAG=""
  GREP_EXTRA_TAG=""
  OUTPUT=$(make docker-push)
else
  EXTRA_TAG=",${1}"
  GREP_EXTRA_TAG="|${1}"
  OUTPUT=$(make docker-push IMAGE_TAG="${1}")
fi

echo "$OUTPUT"

TAG=$(docker images "$(get_env DEV_REPO)/$(get_env IMAGE_NAME)" --format="{{.Tag}}" | grep -v -E "latest|<none>${GREP_EXTRA_TAG}")
echo "TAG: $TAG"
set_env IMAGE_TAG "${TAG}"

DIGEST=$(echo "$OUTPUT" | grep "$TAG: digest: " | sed -e "s/$TAG: digest: //g" | sed -e 's/ size: [0-9]*//g')
echo "$DIGEST"
set_env IMAGE_DIGEST "${DIGEST}"

save_artifact "$(get_env IMAGE_NAME)" "name=$(get_env DEV_REPO)/$(get_env IMAGE_NAME):$TAG" "digest=$DIGEST" "type=image" "tags=${TAG}${EXTRA_TAG}"
