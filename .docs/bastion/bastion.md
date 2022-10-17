# Provisioning a bastion host by using Teleport with Secure Landing Zone

Secure Landing Zone can provision the solution that is described in [Setting up a bastion host that uses Teleport](https://cloud.ibm.com/docs/allowlist/framework-financial-services?topic=framework-financial-services-vpc-architecture-connectivity-bastion-tutorial-teleport) (available by allowlist). This solution configures a bastion host in your VPC using Teleport Enterprise Edition, and provisions a Cloud Object Storage bucket and App ID for enhanced security.

[App ID](https://cloud.ibm.com/docs/appid) is used to authenticate users to Teleport. Teleport session recordings are stored in the Object Storage bucket. The [cloud-init file](../../teleport_config/cloud-init.tpl) file installs teleport and configures App ID and Object Storage. The Teleport [variables.tf](../../teleport_config/variables.tf) file is used for the configuration.

## Before you begin

You need the following items to deploy and configure a bastion host that uses Teleport:

- A Teleport Enterprise Edition license
- A generated SSL certificate and key for each of the provisioned virtual server instances or a wildcard certificate

## Provision with Secure Landing Zone

SLZ can provision the bastion host in two locations. You can place the bastion either within the management VPC or in the edge VPC if you're using BIG-IP from F5.

| Management VPC                                     | Edge or Transit VPC           |
| ---------------------------------------------------| ----------------------------- |
| ![Management](../images/management-teleport.png)   | ![Edge](../images/edge-f5.png)|

### Provisioning a bastion host in the management VPC

To provision Teleport within the management zone, you must set `teleport_management_zones` to the number of bastion hosts to deploy, up to a maximum of 3. For example, if you set the number to `1`, it provisions a bastion host in zone-1 of your management VPC. If you set the number to `2`, it provisions a bastion within zone-1 and zone-2 of your management VPC. Other variables that are needed for the setup and configuration of Teleport are mentioned in the following sections.

### Provisioning a bastion host on the edge VPC with F5 BIG-IP

The `provision_teleport_in_f5` and `add_edge_vpc` variables must both be set to true. For more information about F5 deployment, see [Provisioning a F5 BIG-IP host by using Secure Landing Zone](../f5-big-ip/f5-big-ip.md) and the following variables that are needed for the setup and configuration of Teleport.

Don't set both `create_f5_network_on_management_vpc` to true and `teleport_management_zones` to a value greater than `0`.

### Teleport configuration variables

The following variables need to be set to provision the bastion host using Teleport.

```
provision_teleport_in_f5  # Provision Teleport in the Edge VPC alongside the F5
use_existing_appid        # Use an existing appid instance. If this is false, one will be automatically
appid_name                # Name of appid instance.
appid_resource_group      # Resource group for existing appid instance. This value is ignored if a new instance is created.
teleport_instance_profile # Machine type for Teleport VSI instances. Use the IBM Cloud CLI command `ibmcloud is instance-profiles` to see available image profiles.
teleport_vsi_image_name   # Teleport VSI image name. Use the IBM Cloud CLI command `ibmcloud is images` to see available images.
teleport_license          # The contents of the PEM license file
https_cert                # The https certificate used by bastion host for teleport
https_key                 # The https private key used by bastion host for teleport
teleport_hostname         # The name of the instance or bastion host
teleport_domain           # The domain of the bastion host
teleport_version          # Version of Teleport Enterprise to use
message_of_the_day        # Banner message that is exposed to the user at authentication time
teleport_admin_email      # Email for teleport vsi admin.
teleport_management_zones # Number of zones to create teleport VSI on Management VPC if not using F5. If you are using F5, ignore this value
```

For more details about specifying input variables, see [Customizing your environment](../../README.md#using-terraform-input-variables). For more information about the Teleport configuration variables, see the following documentation for the pattern:

- [VSI](../../patterns/vsi/README.md#module-variables)
- [Mixed](../../patterns/mixed/README.md#module-variables)
- [ROKS](../../patterns/roks/README.md#module-variables)

## Accessing Teleport

After App ID is successfully configured to Teleport, you can log in to Teleport through a web console or tsh client. Tsh is the Teleport client tool that is the command-line tool for Teleport. For more information, see [Installing tsh](https://goteleport.com/docs/server-access/guides/tsh/#installing-tsh). You need the fully qualified domain name (FQDN) of the Teleport server to log in.

### Log in through the web console

1.  Access the web console on port 3080. (`https://<User defined FQDN of teleport server>:3080`)
1.  Start a terminal session under **Servers**. Look for a single server with a connect button. Click **Connect** and select the user that you would like to log in with.

### Log in through the tsh client

1.  Install the [Teleport client tool tsh](https://goteleport.com/docs/server-access/guides/tsh/#installing-tsh)
1.  [Log in using tsh](https://goteleport.com/docs/server-access/guides/tsh/#logging-in).

    ```sh
    tsh login --proxy=<User defined FQDN of teleport server>:3080
    ```

1.  Run the shell or run a command on a remote SSH node by using the [tsh ssh command](https://goteleport.com/docs/setup/reference/cli/#tsh-ssh)

    ```sh
    tsh ssh <[user@]host>
    ```

## Debugging bastion host VSI

You might not be able to access Teleport that is installed on your virtual server after the bastion host is provisioned by the Secure Landing Zone. Follow these steps to login and verify the configuration of your virtual server through SSH.

1.  Connect to your bastion host VSI by using [SSH](https://cloud.ibm.com/docs/vpc?topic=vpc-vsi_is_connecting_linux).

    :information_source: **Tip:** SSH is not allowed by default. You must add rules to the [security groups](https://cloud.ibm.com/vpc-ext/network/securityGroups) and [ACLs](https://cloud.ibm.com/vpc-ext/network/acl) on our virtual server.

1.  Run each of the following commands and check whether the values match the ones that you configured:

    1.  Verify whether the content of the file matches your `teleport_license`:

        ```sh
        cat ~/license.pem
        ```
    1.  Verify whether the content of the file matches your `https_cert`:

        ```sh
        cat ~/cert.pem
        ```

    1.  Verify whether the content of the file equals your `https_key`:

        ```sh
        cat ~/key.pem
        ```

    1.  Verify both that the `redirect_url` value equals `https://<HOSTNAME>.<DOMAIN>:3080/v1/webapi/oidc/callback` and that the `claims_to_roles` value is `- {claim: "email", value: "<TELEPORT_ADMIN_EMAIL>", roles: ["teleport-admin"]}`:

        ```sh
        cat ~/oidc.yaml
        ```

    1.  Verify whether the `audit_sessions_uri` value contains your `cos_bucket_name`:

        ```sh
        cat ~/../etc/teleport.yaml
        ```
    1.  Verify that Teleport is running:

        ```sh
        systemctl status teleport
        ```

1.  After you verify that Teleport is configured correctly, remove the security group and ACL rules you added in Step 1. Alternatively, you can run the script `/root/install.sh` to run the installation again.

## ACL and security groups

By default, Secure Landing Zone provisions ACLs and security groups that are more open and not customer dependent. Use the [override.json](../../README.md#using-overridejson) file to change, add, or delete rules for your environment.
