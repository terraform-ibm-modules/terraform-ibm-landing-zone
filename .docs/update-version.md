# Updating to another release of the Red Hat OpenShift pattern.

With release XXX, the Red Hat OpenShift cluster creation moved from a resource block to a separate module. You can update to the new release of the landing zone without destroying and re-creating your Red Hat OpenShift cluster.

Choose the method that matches how you want to update your module:

- [Modify the Terraform code](#modify-the-terraform-code)
- [Use the Terraform CLI](#use-the-terraform-cli)
- [Use Schematics](#use-schematics)

## Update by modifying the Terraform code

To update your Terraform code directly, following these steps.

1.  Edit the `moved_config.tf` file by adding the following lines:

    ```tf
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

1.  Run `terraform plan` and check the output. When you're satisfied with the output, run `terraform apply` to update to the new release.

## Update by using the Terraform CLI

To update your code with the Terraform CLI, follow these steps.

1.  Run this command to retrieve the cluster names from the state file.

    ```tf
    terraform state list | grep "ibm_container_vpc_cluster.cluster"
    ```

1.  Copy the cluster name from the list. For example, `debug-ocp-management-cluster`, `debug-ocp-workload-cluster`
1.  Run `terraform init` to initialize the newly added resources.
1.  Run the following command for each element in the list:

    ```tf
    terraform state mv 'module.landing_zone.ibm_container_vpc_cluster.cluster["<cluster name>"]' 'module.landing_zone.module.cluster["<cluster name>"].ibm_container_vpc_cluster.cluster[0]'
    ```

1.  Run `terraform apply` to apply the changes to the infrastructure without re-creating cluster.
1.  (Optional) If you have worker pools other than the default pool, also move them to prevent them from being destroyed and re-created. As in the previous steps, run the following commands:

    1.  Run the command to get a list of all the worker pools.

        ```tf
        terraform state list | grep "ibm_container_vpc_worker_pool.pool"
        ```

    1.  Separate the cluster name and the worker pool name. For example, you might get something similar to the following output:

        ```tf
        module.landing_zone.ibm_container_vpc_worker_pool.pool["debug-ocp-workload-cluster-logging-worker-pool"]
        ```

        In this case, the cluster_name is `debug-ocp-workload-cluster` and the worker_pool_name is `logging-worker-pool`.

    1.  For each element in the list, run the following command:

        ```tf
        terraform state mv 'module.landing_zone.ibm_container_vpc_worker_pool.pool["<cluster_name>-<worker_pool_name>"]' 'module.landing_zone.module.cluster["<cluster_name>"].ibm_container_vpc_worker_pool.pool["<worker_pool_name>"]'
        ```

## Update by using Schematics

If you deployed the landing zone by using a Schematics workspace, use the following commands to update to the release.

1.  Get the cluster name from the template:

    1.  Find the template ID:

        ```sh
        ibmcloud schematics workspace get --id <workspace_ID>
         ```

         The output includes the template ID in the `Template Variables for` field.

    1.  Run the following command with the template ID:

    ```sh
    ibmcloud schematics state pull --id WORKSPACE_ID --template TEMPLATE_ID | jq -r '.outputs.cluster_names.value'
    ```

1.  Copy the cluster name from the list, as in the following example:

    ```tf
    [
      "debug-ocp-management-cluster",
      "debug-ocp-workload-cluster"
    ]
    ```

1.  For each element in the list, run the following command:

    ```sh
    ibmcloud schematics workspace state mv --id WORKSPACE_ID --source 'module.landing_zone.ibm_container_vpc_cluster.cluster["<cluster_name>"]' --destination 'module.landing_zone.module.cluster["<cluster_name>"].ibm_container_vpc_cluster.cluster[0]'
    ```

1.  Update the offering version.
