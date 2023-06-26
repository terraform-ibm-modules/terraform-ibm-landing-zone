## Updating to another version of the Red Hat OpenShift pattern.

During this specific version release we are moving the Red Hat OpenShift cluster creation from resource block to a seperate module. You can update to the new release of the SLZ without destroying and recreating your Red Hat OpenShift cluster. Choose the method that matches how you work with the module:

- Modify the Terraform code
- Use the Terraform CLI
- Use Schematics

### 1. Modify the Terraform code:
1. Prior to `terraform plan` and `terraform apply`. Edit `moved_config.tf`
2. Add the following lines to the terraform file.
  ```
  moved {
    from = ibm_container_vpc_cluster.cluster["<workload_cluster_name>"]
    to   = module.cluster["<workload_cluster_name>"].ibm_container_vpc_cluster.cluster[0]
  }
  moved {
    from = ibm_container_vpc_cluster.cluster["<management_cluster_name>"]
    to   = module.cluster["<management_cluster_name>"].ibm_container_vpc_cluster.cluster[0]
  }
  ```
    Where `<workload_cluster_name>` and `<management_cluster_name>` are your workload cluster and management cluster names.
3. Go ahead with `terraform plan` and `terraform apply`.

### 2. Use the Terraform CLI:
1. Run this command to retrive the cluster names from the state file.
```
  terraform state list | grep "ibm_container_vpc_cluster.cluster"
```
2. Take the cluster name from the list. For example: `debug-ocp-management-cluster`, `debug-ocp-workload-cluster`
3. Run `terraform init` to initialize newly added resources.
4. For each element in the list:
```
terraform state mv 'module.landing_zone.ibm_container_vpc_cluster.cluster["<cluster name>"]' 'module.landing_zone.module.cluster["<cluster name>"].ibm_container_vpc_cluster.cluster[0]'
```
5. Run `terraform apply` to apply the changes to the infrastructure without re-creating cluster.

6. (Optional) If you have additional worker pools other than the default pool. You will need to move them as well to prevent destroy and recreate. Similiar to the previous steps run the following.

    a. Run the command to get a list of all the workerpools.
    `terraform state list | grep "ibm_container_vpc_worker_pool.pool"`

    b. Seperate the cluster name and the worker pool name. For example, you might get a output similiar to this:
    ```
    module.landing_zone.ibm_container_vpc_worker_pool.pool["debug-ocp-workload-cluster-logging-worker-pool"]
    ```
    cluster_name : debug-ocp-workload-cluster
    worker_pool_name : logging-worker-pool

    c. For each element in the list, Run the following:
    `terraform state mv 'module.landing_zone.ibm_container_vpc_worker_pool.pool["<cluster_name>-<worker_pool_name>"]' 'module.landing_zone.module.cluster["<cluster_name>"].ibm_container_vpc_worker_pool.pool["<worker_pool_name>"]'`

### 3. Use Schematics:

If you have the SLZ deployed using schematics workspace. You can use the following commands:

1. Run this command to get the cluster names.
```
ibmcloud schematics state pull --id WORKSPACE_ID --template TEMPLATE_ID | jq -r '.outputs.cluster_names.value'
```
To find the ID of the template, run `ibmcloud schematics workspace get --id <workspace_ID>` and find the template ID in the Template Variables for: field of your command-line output.

2. Take the cluster name from the list. For example:
```
[
  "debug-ocp-management-cluster",
  "debug-ocp-workload-cluster"
]
```
3. For each element in the list:
```
ibmcloud schematics workspace state mv --id WORKSPACE_ID --source 'module.landing_zone.ibm_container_vpc_cluster.cluster["<cluster_name>"]' --destination 'module.landing_zone.module.cluster["<cluster_name>"].ibm_container_vpc_cluster.cluster[0]'
```

4. Now you can go ahead and update the Offering version.
