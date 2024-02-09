#!/usr/bin/env bash
# For use within Tekton pipeline

if [[ "$PIPELINE_DEBUG" == 1 ]]; then
  trap env EXIT
  env
  set -x
fi

# always publish a latest tag
EXTRA_TAGS="latest"

# supports also passing in comma separated list of extra tags (e.g. publish.sh tag1,tag2,tag3)
if [ -n "$1" ];then
  EXTRA_TAGS="${EXTRA_TAGS},${1}"
fi

if "${ONE_PIPELINE_PATH}"/internal/pipeline/evaluator_ci; then

  ibmcloud_api_key=$(get_env ciso-ibmcloud-api-key "")
  if [[ -z "$ibmcloud_api_key" ]]; then
    ibmcloud_api_key=$(get_env ibmcloud-api-key)
  fi

  echo "Copying image to production registry"
  skopeo copy --remove-signatures \
  --dest-creds iamapikey:"${ibmcloud_api_key}" --src-creds iamapikey:"${ibmcloud_api_key}" \
  "docker://$(get_env DEV_REPO)/$(get_env IMAGE_NAME):$(get_env IMAGE_TAG)" \
  "docker://$(get_env PROD_REPO)/$(get_env IMAGE_NAME):$(get_env IMAGE_TAG)"

  IFS=" " read -r -a tags_array <<< "${EXTRA_TAGS//,/ }"
  for tag in "${tags_array[@]}"; do
    skopeo copy --remove-signatures \
    --dest-creds iamapikey:"${ibmcloud_api_key}" --src-creds iamapikey:"${ibmcloud_api_key}" \
    "docker://$(get_env PROD_REPO)/$(get_env IMAGE_NAME):$(get_env IMAGE_TAG)" \
    "docker://$(get_env PROD_REPO)/$(get_env IMAGE_NAME):${tag}"
  done
  save_artifact "$(get_env IMAGE_NAME)" "name=$(get_env PROD_REPO)/$(get_env IMAGE_NAME):$(get_env IMAGE_TAG)" "digest=$(get_env IMAGE_DIGEST)" "type=image" "tags=$(get_env IMAGE_TAG),${EXTRA_TAGS}"
  echo "Sign image"
  /opt/commons/ciso/sign_icr.sh
else
  echo "Failed checks not publishing"
  set_env STAGE_RELEASE_STATUS "failed"
fi
