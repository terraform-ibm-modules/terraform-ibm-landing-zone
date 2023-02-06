#!/bin/bash

## Subscriptions are set for manual approval. This script approves the first installplan for the initial install

approve_install_plan(){
    local subscription_name=$1
    local namespace=$2
    local timeout_secs=900

    echo "Waiting for installplan $subscription_name (${timeout_secs}s timeout)..."

    local install_plan

    # if running on MAC OS use "gtimeout" else run default "timeout" (
    local timeout_cmd=timeout
    if [[ $OSTYPE == 'darwin'* ]]; then
        # If gtimeout not detected on mac, install coreutils
        if ! gtimeout --help &> /dev/null; then
            brew install coreutils
        fi
        timeout_cmd=gtimeout
    fi
    # shellcheck disable=SC2016
    install_plan="$($timeout_cmd $timeout_secs bash -c 'while [[ "$(kubectl get subscription "'"$subscription_name"'" -n "'"$namespace"'" -o jsonpath="{$.status.installplan.name}")" == "" ]]; do sleep 2; done; echo $(kubectl get subscription service-mesh-operator -n "'"$namespace"'" -o jsonpath="{$.status.installplan.name}")')"

    if [[ $install_plan != "" ]]
    then
        echo "Install plan $install_plan found"
        echo "Approving install plan $install_plan"
        kubectl patch installplan "$install_plan" --type merge --patch "{\"spec\":{\"approved\":true}}" -n "$namespace"
    else
        echo "Error: Install plan for $subscription_name was not found (namespace: $namespace)"
        echo "Grabbing some debug info..."
        echo
        echo "kubectl get pods -n openshift-marketplace -o wide"
        kubectl get pods -n openshift-marketplace -o wide
        echo
        echo "kubectl get installplan -n $namespace"
        kubectl get installplan -n "$namespace"
        echo
        echo "kubectl get subscription $subscription_name -n $namespace"
        kubectl get subscription "$subscription_name" -n "$namespace"
        exit 1
    fi

    echo "Waiting for installplan ($subscription_name) to be installed (${timeout_secs}s timeout)..."
    kubectl wait --for=condition=Installed --timeout ${timeout_secs}s installplan/"$install_plan" -n "$namespace"
}

wait_for_operator(){
    local subscription_name=$1
    local namespace=$2

    echo "Waiting for $subscription_name operator to be running in $namespace (360s timeout)..."
    local sm_csv=""

    until [[ $sm_csv != "" ]]
    do
        echo "Waiting for csv to be created for subscription $subscription_name"
        sm_csv=$(kubectl get subscription "$subscription_name" -o jsonpath="{$.status.installedCSV}" -n "$namespace")
        sleep 5
    done

    local loop_count=0
    echo "CSV found. Waiting for $subscription_name operator to be running"
    until [[ $(kubectl get csv "$sm_csv" -o jsonpath="{$.status.phase}" -n "$namespace") == "Succeeded" || $loop_count -gt 72 ]]
    do
        echo "Still waiting for $subscription_name operator to be running"
        sleep 5
        loop_count=$((loop_count+1))
    done

    if [[ $loop_count -gt 72 ]]
    then
        echo "Giving up - $subscription_name operator is not running. Check the status of the operator in the $namespace namespace."
        exit 1
    fi

    echo "Complete: $subscription_name operator is running"
}

### Main ###

namespace=$1

## Wait for, and approve install plan for service-mesh-operator
approve_install_plan "service-mesh-operator" "$namespace"

subscription_names=( "service-mesh-operator" )
## Post install waits
for subscription_name in "${subscription_names[@]}"
do
    wait_for_operator "$subscription_name" "$namespace"
done

echo "Service Mesh Operators: Install complete"
