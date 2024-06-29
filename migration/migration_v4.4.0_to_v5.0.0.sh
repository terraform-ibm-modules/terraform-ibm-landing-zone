#!/bin/bash

### NOTE: Make sure the clusters are openshift clusters as the SLZ has been updated to only support ROKS cluster creation using module. If there are IKS cluster being tracked in the state file please use the terraform cli to manually move the ROKS clusters. Please refer to the https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/blob/extend-output/migration/update-version.md on steps to run terraform cli commands.

# Run Terraform init to import new modules
terraform init

# Get list of old clusters to be moved
old_clusters="$(terraform state list | grep "ibm_container_vpc_cluster.cluster")"

# Loop to get the cluster name and run terraform mv command
for cluster in "${old_clusters[@]}"; do
    pre="$(echo "$cluster" | rev | cut -d '.' -f 3- | rev)"
    cluster_name="$(echo "$cluster" | awk -F'["]' '{for(i=2;i<=NF;i+=2) print $i}')"
    terraform state mv "$cluster" "$pre.module.cluster[\"$cluster_name\"].ibm_container_vpc_cluster.cluster[0]"
done

# Get list of worker pools to be moved
old_worker_pool="$(terraform state list | grep "ibm_container_vpc_worker_pool.pool")"

# Run only if additional worker pools are present other than the default pool
if ((${#old_worker_pool[@]})); then
    for pool in "${old_worker_pool[@]}"; do
        for cluster in "${old_clusters[@]}"; do
            cluster_name="$(echo "$cluster" | awk -F'["]' '{for(i=2;i<=NF;i+=2) print $i}')"
            if [[ $pool == *"$cluster_name"* ]]; then
                pre="$(echo "$cluster" | sed -E 's/(([^.]*\.){3}[^.]*)\..*/\1/')"
                post="$(echo "$cluster" | sed -E 's/\..*(([^.]*\.){1}[^.]*)/\1/')"
                old_pool_name="$(echo "$pool" | awk -F'["]' '{for(i=2;i<=NF;i+=2) print $i}'))"
                pool_name=${old_pool_name//$cluster_name-/}
                terraform state mv "$pool" "$pre"."$post".ibm_container_vpc_worker_pool.pool[\""$pool_name"\"]
            fi
        done
    done
fi
