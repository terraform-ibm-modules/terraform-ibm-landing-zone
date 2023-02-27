# Private Cluster Endpoint

You can use this example to deploy a fully private cluster in the workload vpc.

Steps to create a private cluster with a private cluster endpoint which can only be accesssed from a jumpbox which is located in the management vpc:

1. On your local environment, go the `one-vpc-one-vsi` folder and run the following commands to configure management vpc and a vsi which will act as a jumpbox.
    ```
    export TF_VAR_ibmcloud_api_key=<your api key> # pragma: allowlist secret
    terraform init
    terraform apply -var=ssh_key='ssh-rsa ...' -var=region=eu-gb -var=prefix=my_slz
    ```
2. Once the jumpbox has been created. SSH into the jumpbox using its floating IP and the private ssh key used to provision the vsi server.
    ``` ssh -i <private>.pem root@<floating_IP>```
3. Configure Git and required dependencies like `make`,`Docker`, `ibmcloud CLI`.
4. Clone the [Terraform Landing Zone Repo](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone.git) and run `make docker-run` to run a container with all the required dependecies to run the module.
5. Now, in the container running on the jumpbox, go to the `examples/private-endpoint-example/one-vpc-one-roks` folder and run the following commands to create a workload cluster on the workload vpc.
    ```
    export TF_VAR_ibmcloud_api_key=<your api key> # pragma: allowlist secret
    terraform init
    terraform apply -var=region=eu-gb -var=prefix=my_slz
    ```
    NOTE: Make sure the region and the prefix used for the vsi creation and the roks cluster is the same.

6. Once the roks cluster is created. You can connect to the private roks cluster from the jumpbox. [see the docs](https://cloud.ibm.com/docs/openshift?topic=openshift-access_cluster)
