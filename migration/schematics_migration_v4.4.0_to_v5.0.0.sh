#!/bin/bash

### NOTE: Make sure the clusters are openshift clusters as the SLZ has been updated to only support ROKS cluster creation using module. If there are IKS cluster being tracked in the state file please use the terraform cli to manually move the ROKS clusters. Please refer to the https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/blob/extend-output/migration/update-version.md on steps to run terraform cli commands.

if [ -z "$1" ]; then
    echo "ERROR::Please ensure you provide correct Workspace ID as the parameter and try again"
else
    WS_ID=$1
    template_id="$(ibmcloud schematics workspace get --id "$WS_ID" -o json | jq -r .template_data[0].id)"
    old_clusters="$(ibmcloud schematics state pull --id "$WS_ID" --template "$template_id" | jq -r '.outputs.cluster_names.value' | tr -d '[]," ')"

    for cluster in "${old_clusters[@]}"; do
        ibmcloud schematics workspace state mv --id "$WS_ID" --source "module.landing_zone.ibm_container_vpc_cluster.cluster[\"$cluster\"]" --destination "module.landing_zone.module.cluster[\"$cluster\"].ibm_container_vpc_cluster.cluster[0]"
        sleep 60
        while true; do
            status=$(ibmcloud schematics workspace get --id "$WS_ID" -o json | jq -r .status)
            echo "$status"
            if [[ "$status" == "ACTIVE" ]]; then
                echo "Changes done to $cluster"
                break
            elif [[ "$status" == "FAILED" ]]; then
                echo "ERROR::Unfortunately, the Schematics workspace is in a FAILED state. Please review the workspace and try running the following command manually:"
                echo "ibmcloud schematics workspace state mv --id ""$WS_ID"" --source 'module.landing_zone.ibm_container_vpc_cluster.cluster[\"$cluster\"]' --destination 'module.landing_zone.module.cluster[\"$cluster\"].ibm_container_vpc_cluster.cluster[0]'"
                break
            fi
            sleep 10
            status=""
        done
    done

    old_worker_pools="$(ibmcloud schematics state pull --id "$WS_ID" --template "$template_id" | jq -r '.resources[] | select(.instances[].attributes.worker_pool_name != null) | .instances[].index_key' | sort -u)"

    if ((${#old_worker_pools[@]})); then
        for pool in "${old_worker_pools[@]}"; do
            for cluster in "${old_clusters[@]}"; do
                if [[ $pool == *"$cluster"* ]]; then
                    pool_name=${pool//$cluster_name-/}
                    ibmcloud schematics workspace state mv --id "$WS_ID" --source "module.landing_zone.ibm_container_vpc_worker_pool.pool[\"$pool\"]" --destination "module.landing_zone.module.cluster[\"$cluster\"].ibm_container_vpc_worker_pool.pool[\"$pool_name\"]"
                    sleep 60
                    while true; do
                        status=$(ibmcloud schematics workspace get --id "$WS_ID" -o json | jq -r .status)
                        echo "$status"
                        if [[ "$status" == "ACTIVE" ]]; then
                            echo "Changes done to $pool"
                            break
                        elif [[ "$status" == "FAILED" ]]; then
                            echo "ERROR::Unfortunately, the Schematics workspace is in a FAILED state. Please review the workspace and try running the following command manually:"
                            break
                        fi
                        sleep 10
                        status=""
                    done
                fi
            done
        done
    fi
fi
