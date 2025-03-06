---

copyright:
  years: 2025
lastupdated: "2025-03-05"

keywords:

subcollection: deployable-reference-architectures

authors:
  - name: "Andrej Kocbek"

# The release that the reference architecture describes
version: 2.1.3

# Whether the reference architecture is published to Cloud Docs production.
# When set to false, the file is available only in staging. Default is false.
production: false

# Use if the reference architecture has deployable code.
# Value is the URL to land the user in the IBM Cloud catalog details page
# for the deployable architecture.
# See https://test.cloud.ibm.com/docs/get-coding?topic=get-coding-deploy-button
deployment-url: https://cloud.ibm.com/catalog/7a4d68b4-cf8b-40cd-a3d1-f49aff526eb3/architecture/deploy-arch-ibm-client-to-site-vpn-1b824983-263f-4191-bfcd-c1d1b2220aa3-global

docs: https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-connect-landingzone-client-vpn

image_source: https://github.com/terraform-ibm-modules/terraform-ibm-client-to-site-vpn/blob/main/reference-architectures/c2s-basic.drawio.svg

related_links:
  - title: "VPC landing zone - Standard variation"
    url: "https://cloud.ibm.com/docs/deployable-reference-architectures?topic=deployable-reference-architectures-vsi-ra"
    description: "A deployable architecture that is based on the IBM Cloud for Financial Services reference and that provides virtual servers in a secure VPC for your workloads."

use-case: Cybersecurity
industry: Banking,FinancialSector
compliance: FedRAMP

content-type: reference-architecture

---

{{site.data.keyword.attribute-definition-list}}

# Cloud automation for Client to Site VPN
{: #vpn-ra}
{: toc-content-type="reference-architecture"}
{: toc-industry="Banking,FinancialSector"}
{: toc-use-case="Cybersecurity"}
{: toc-compliance="FedRAMP"}
{: toc-version="2.1.0"}

This deployable architecture pattern configures client-to-site VPN secure and encrypted server connectivity within an existing management VPC using only a few required inputs. Once deployed, you can install an OpenVPN client application on the devices you wish to use for VPN access, and import a profile from the VPN server. The configuration also allows you to specify a list of users who will have access to the private network, with access control managed by IBM Cloud IAM.

## Architecture diagram
{: #ra-vpn-ext-architecture-diagram}

![Architecture diagram for adding client-to-site VPN to a landing zone deployable architecture](c2s-basic.drawio.svg "Architecture diagram for adding client-to-site VPN to a landing zone deployable architecture"){: caption="Figure 1. client-to-site VPN on existing landing zone" caption-side="bottom"}{: external download="c2s-basic.drawio.svg"}

## Design requirements
{: #ra-vpn-ext-design-requirements}

![Design requirements for VPN on management VPC landing zone](heat-map-deploy-arch-slz-vpn "Design requirements"){: caption="Figure 2. Scope of the design requirements" caption-side="bottom"}

<!--
TODO: Add the typical use case for the architecture.
The use case might include the motivation for the architecture composition,
business challenge, or target cloud environments.
-->
## Components
{: #ra-vpn-components}

### Client-to-site VPN architecture decisions
{: #ra-vpn-components-arch}

| Requirement | Component | Reasons for choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
| Set up secure client-to-site VPN | VPN | | |
| Store private certificate in existing Secrets Manager | Secrets Manager | Create and store private certificate to ensure secure communication and authentication between public network and the private VPC | |

### Network security architecture decisions
| Requirement | Component | Reasons for choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
| Load VPN configuration to simplify VPN setup | VPNs | Open following ports by default: 53 (DNS service), 443 (https) | |
| Create two subnets to achieve high availability | VPC | Distributing resources across two subnets allows for load balancing between them, ensuring that no single point of failure affects the performance or availability of client-to-site VPN | |
| * Create connection to isolated existing management VPC and allow only a limited number of network connections  \n * All other connections from or to existing management VPC are forbidden | ACL and security group rules in client-to-site VPN| | More ports might be opened in preset or added manually after deployment |
{: caption="Table 2. Network security architecture decisions" caption-side="bottom"}

<!--
## Compliance
{: #ra-vpn-ext-compliance}

_Optional section._ Feedback from users implies that architects want only the high-level compliance items and links off to control details that team members can review. Include the list of control profiles or compliance audits that this architecture meets. For controls, provide "learn more" links to the control library that is published in the IBM Cloud Docs. For audits, provide information about the compliance item.
-->

## Next steps
{: #ra-vpn-ext-next-steps}

- See the landing zone [deployment guide](https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-overview).
