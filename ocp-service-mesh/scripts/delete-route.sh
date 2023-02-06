#!/bin/bash

set -e

namespace=$1

# Retry for 2mins, then give up
RETRIES=24
WAIT=5
COMMAND="oc delete route -n ${namespace} istio-ingressgateway"

counter=1
while [ ${counter} -le ${RETRIES} ]; do
  echo "Executing command: ${COMMAND}"
  if ! ${COMMAND}; then
    echo "istio-ingressgateway route deletion failed, retrying in ${WAIT}s. (retry attempt ${counter}/${RETRIES})"
    sleep ${WAIT}
    ((counter=counter+1))
  else
    break
  fi
done
if [ "${counter}" -gt ${RETRIES} ]; then
  echo "Maximum attempts reached, giving up"
  exit 1
fi
