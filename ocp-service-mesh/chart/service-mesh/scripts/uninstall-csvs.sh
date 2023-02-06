#!/bin/bash

## Needed to delete resources (CSVs) created by the OLM outside of the Terraform scope

operator_names=( "service-mesh-operator" )

echo "Fetching and deleting CSVs for Service Mesh Operators"

for i in "${operator_names[@]}"
do
    CSV=$(kubectl get subscription "$i" -o jsonpath="{$.status.installedCSV}" -n "$1")

    if [ -n "$CSV" ]
    then
        echo "Deleting CSV ${CSV}"
        kubectl delete csv "$CSV" -n "$1"
    fi
done
