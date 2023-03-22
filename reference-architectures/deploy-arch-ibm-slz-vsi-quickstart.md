---

copyright:
  years: 2023
lastupdated: "2023-03-22"

keywords:

subcollection: secure-infrastructure-vpc

authors:
  - name: "Vincent Burckhardt"
    email: "vincent.burckhardt@ie.ibm.com"

# The release that the reference architecture describes
version: 1.0

# Use if the reference architecture has deployable code.
# Value is the URL to land the user in the IBM Cloud catalog details page
# for the deployable architecture.
# See https://test.cloud.ibm.com/docs/get-coding?topic=get-coding-deploy-button
deployment-url: url #TODO

docs: https://test.cloud.ibm.com/docs/secure-infrastructure-vpc

image_source: https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/reference-architectures/vsi-pattern.png

related_links:
  - title: "Secure infrastructure on VPC for regulated industries - Standard variation"
    url: "https://cloud.ibm.com/docs/deployable-reference-architectures?topic=deployable-reference-architectures-vsi-ra"
    description: "A deployable architecture that is based on the IBM Cloud for Financial Services reference and that provides virtual servers in a secure VPC for your workloads."

use-case: Cybersecurity
industry: Banking,FinancialSector
compliance: FedRAMP

content-type: reference-architecture

---

{{site.data.keyword.attribute-definition-list}}

<!--
Don't include "reference architecture" in the following title.
Specify a title based on a use case. If the architecture has a module
or tile in the IBM Cloud catalog, match the title to the catalog. See
https://test.cloud.ibm.com/docs/solution-as-code?topic=solution-as-code-naming-guidance.
-->

# Secure infrastructure on VPC for regulated industries - QuickStart variation
{: #vsi-ra-qs}
{: toc-content-type="reference-architecture"}
{: toc-industry="Banking,FinancialSector"}
{: toc-use-case="Cybersecurity"}
{: toc-compliance="FedRAMP"}

The QuickStart variation of the Secure infrastructure on VPC for regulated industries deployable architecture creates a fully customizable Virtual Private Cloud (VPC) environment in a single region. The solution provides virtual servers in a secure VPC for your workloads. The QuickStart variation is designed to deploy quickly for demonstration and development.

# Architecture diagram
{: #ra-vsi-qs-architecture-diagram}

![Architecture diagram for the QuickStart variation of Secure infrastructure on VPC for regulated industries](vsi-quickstart.drawio.svg "Architecture diagram of VSI on VPC for regulated industries deployable architecture"){: caption="Figure 1. QuickStart variation of Secure infrastructure on VPC for regulated industries" caption-side="bottom"}

## Design requirements
{: #ra-vsi-qs-qs-design-requirements}

![Design requirements for Secure infrastructure on VPC for regulated industries](heat-map-deploy-arch-slz-vsi.svg "Design requirements"){: caption="Figure 2. Scope of the design requirements" caption-side="bottom"}

<!--
TODO: Add the typical use case for the architecture.
The use case might include the motivation for the architecture composition,
business challenge, or target cloud environments.
-->
## Components
{: #ra-vsi-qs-components}

### VPC architecture decisions
{: #ra-vsi-qs-components-arch}

| Requirement | Component | Reasons for choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
| * Ensure public internet connectivity  \n * Isolate most virtual instances to not be reachable directly from the public internet | Edge VPC service|Create a separate VPC service where public internet connectivity is allowed to be configured | |
| * Provide infrastructure administration access  \n * Limit the number of infrastructure administration entry points to ensure security audit | Management VPC service | Create a separate VPC service where SSH connectivity from outside is allowed | |
| * Provide infrastructure for service management components like backup, monitoring, IT service management, shared storage  \n * Ensure you can reach all IBM Cloud and on-premises services | Workload VPC service|Create a separate VPC service as an isolated environment, without direct public internet connectivity and without direct SSH access | |
| Create a virtual server instance that can act as an internet proxy server | Proxy server VPC instance | Create a Linux VPC instance that can act as a proxy server. Configure ACL and security group rules to allow public internet traffic over proxy that uses default proxy ports (3828) | Configure application load balancer to act as proxy server manually |
| Create a virtual server instance as the only management access point to the landscape | Bastion host VPC instance | Create a Linux VPC instance that acts as a bastion host. Configure ACL and security group rules to allow SSH connectivity (port 22). Add a public IP address to the VPC instance. Allow connectivity from a restricted and limited number of public IP addresses. Allow connectivity from IP addresses of the Schematics engine nodes | |
|  Create a virtual server instance to host basic management services like DNS, NTP, NFS | Management services VPC instance | Create a Linux VPC instance that can host management components. Configure ACL and security group rules to allow communication for basic management components. | Modify number of virtual server instances and allowed ports in preset, or modify them manually |
| * Set up network for all created services  \n * Isolate network for all created services  \n * Ensure all created services are interconnected | Secure landing zone components | Create a minimum set of required components for a secure landing zone | Create a modified set of required components for a secure landing zone in preset |
{: caption="Table 1. Architecture decisions" caption-side="bottom"}

### Network security architecture decisions
{: #ra-vsi-qs-components-arch-net-sec}

| Requirement | Component | Reasons for choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
| * Isolate management VPC and allow only a limited number of network connections  \n * All other connections from or to management VPC are forbidden | ACL and security group rules in management VPC|Open following ports by default: 22 (for limited number of IPs)  \n All ports to other VPCs are open |More ports might be opened in preset or added manually after deployment |
| * Isolate workload VPC and allow only a limited number of network connections  \n * All other connections from or to workload VPC are forbidden | ACL and security group rules in workload VPC | Open following ports by default: 53 (DNS service)  \n All ports to other VPCs are open | More ports might be opened in preset or added manually after deployment |
| Enable floating IP on bastion host to execute deployment | Floating IPs on bastion host in management VPC|Use floating IP on bastion host from IBM Schematics to complete deployment | |
| Load VPN configuration to simplify VPN setup | VPNs | VPN configuration is the responsibility of the customer | |
{: caption="Table 2. Network security architecture decisions" caption-side="bottom"}

### Key and password management architecture decisions
{: #ra-vsi-qs-components-arch-key-pw}

| Requirement | Component | Reasons for choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
| * Use public and private SSH keys to access virtual server instances by using SSH  \n * Use SSH proxy to log in to all virtual server instances by using the bastion host  \n * Do not store private SSH key on any virtual instances, also not on the bastion host  \n * Do not allow any other SSH login methods except the one with the specified public and private SSH key pair | Public and private SSH keys provided by customer | Ask customer to specify the keys. Accept the input as secure parameter or as reference to the key stored in IBM Cloud Secure Storage Manager. Do not print SSH keys in any log files. Do not persist private SSH key. | |
{: caption="Table 3. Key and passwords management architecture decisions" caption-side="bottom"}

<!--
## Compliance
{: #ra-vsi-qs-compliance}

TODO: Decide whether to include a compliance section, and if so, add that information

_Optional section._ Feedback from users implies that architects want only the high-level compliance items and links off to control details that team members can review. Include the list of control profiles or compliance audits that this architecture meets. For controls, provide "learn more" links to the control library that is published in the IBM Cloud Docs. For audits, provide information about the compliance item.
 -->

<!--
## Next steps
{: #ra-vsi-qs-next-steps}

TODO: Decide what next steps to list, if any

Optional section. Include links to your deployment guide or next steps to get started with the architecture. -->
