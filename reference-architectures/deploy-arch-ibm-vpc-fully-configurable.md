---

copyright:
  years: 2025
lastupdated: "2025-09-02"

keywords:

subcollection: deployable-reference-architectures

authors:
  - name: "Jordan Williams"

# The release that the reference architecture describes
version: 8.1.0

# Whether the reference architecture is published to Cloud Docs production.
# When set to false, the file is available only in staging. Default is false.
production: true

# Use if the reference architecture has deployable code.
# Value is the URL to land the user in the IBM Cloud catalog details page
# for the deployable architecture.
# See https://test.cloud.ibm.com/docs/get-coding?topic=get-coding-deploy-button
deployment-url: https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-vpc-2af61763-f8ef-4527-a815-b92166f29bc8-global

docs: https://cloud.ibm.com/docs/secure-infrastructure-vpc

image_source: https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc/blob/main/reference-architecture/deployable-architecture-vpc.svg

related_links:
  - title: "Cloud foundation for VPC"
    url: "https://cloud.ibm.com/docs/deployable-reference-architectures?topic=deployable-reference-architectures-vpc-fully-configurable"
    description: "A deployable architecture that provides a foundational IBM Cloud Virtual Private Cloud (VPC) environment with full configurability and flexibility for diverse workloads."

use-case: Cybersecurity
industry: Banking,FinancialSector
compliance: FedRAMP

content-type: reference-architecture

---

{{site.data.keyword.attribute-definition-list}}

# Cloud foundation for VPC - Fully configurable variation
{: #vpc-fully-configurable}
{: toc-content-type="reference-architecture"}
{: toc-industry="Banking,FinancialSector"}
{: toc-use-case="Cybersecurity"}
{: toc-compliance="FedRAMP"}
{: toc-version="1.0.0"}

The Cloud foundation for VPC deployable architecture sets up a foundational IBM Cloud Virtual Private Cloud (VPC) environment with full configurability and flexibility. This deployable architecture provides complete control over VPC configuration, including subnets, network ACLs, security groups, public gateways, VPN gateways, and VPE gateways. Unlike pre-configured variations, this solution allows you to customize every aspect of your VPC infrastructure to meet specific requirements.

This architecture lays the groundwork for adding Virtual Server Instances (VSI), Red Hat OpenShift clusters, and other advanced resources. It can be used as a base deployable architecture for many other solutions or as a standalone VPC infrastructure deployment.

## Architecture diagram
{: #ra-vpc-fully-configurable-architecture-diagram}

![Architecture diagram for the Fully configurable variation of Cloud foundation for VPC](https://raw.githubusercontent.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc/main/reference-architecture/deployable-architecture-vpc.svg "Architecture diagram of VPC deployable architecture"){: caption="Figure 1. Fully configurable variation of Cloud foundation for VPC" caption-side="bottom"}{: external download="deployable-architecture-vpc.svg"}

## Components
{: #ra-vpc-fully-configurable-components}

### VPC architecture decisions
{: #ra-vpc-fully-configurable-components-arch}

| Requirement | Component | Reasons for choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
| * Provide flexible VPC infrastructure foundation  \n * Support diverse workload requirements  \n * Enable customization for specific use cases | Fully configurable VPC | Offers complete control over VPC configuration including subnets, zones, and networking components | Use pre-configured VPC patterns with limited customization options |
| * Create isolated network segments  \n * Support multi-zone deployments  \n * Enable proper subnet planning | Configurable subnets | Create one to three zones with customizable subnet configurations in each zone | Use default subnet configurations |
| * Control network traffic at subnet level  \n * Implement security policies  \n * Meet compliance requirements | Network ACLs | Create network ACLs with multiple customizable rules (up to 25 rules per ACL) | Use default VPC ACL rules |
| * Manage instance-level security  \n * Control application traffic  \n * Implement fine-grained access control | Security groups | Configurable security group rules for precise traffic control | Use default security group settings |
{: caption="Table 1. VPC architecture decisions" caption-side="bottom"}

### Network connectivity architecture decisions
{: #ra-vpc-fully-configurable-components-arch-connectivity}

| Requirement | Component | Reasons for choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
| * Enable internet access for VPC resources  \n * Support hybrid cloud architectures  \n * Provide controlled external connectivity | Public gateways | Optionally create public gateways in each zone for internet access | Deploy without public gateways for private-only environments |
| * Establish secure connections to on-premises  \n * Support hybrid cloud deployments  \n * Enable encrypted site-to-site connectivity | VPN gateways | Create VPN gateways with configurable connections for secure hybrid connectivity | Use IBM Cloud Direct Link or other connectivity options |
| * Access IBM Cloud services privately  \n * Avoid public internet traffic  \n * Improve security and performance | VPE gateways | Create Virtual Private Endpoints for private access to IBM Cloud services | Access services over public internet |
| * Support advanced DNS scenarios  \n * Enable cross-VPC communication  \n * Implement hub-and-spoke topologies | DNS configuration | Configurable hub and spoke DNS-sharing model with custom resolvers | Use default VPC DNS settings |
{: caption="Table 2. Network connectivity architecture decisions" caption-side="bottom"}

### Flexibility and customization architecture decisions
{: #ra-vpc-fully-configurable-components-arch-flexibility}

| Requirement | Component | Reasons for choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
| * Support various deployment patterns  \n * Enable integration with existing infrastructure  \n * Provide deployment flexibility | Existing VPC support | Option to deploy into existing VPC infrastructure | Always create new VPC |
| * Meet diverse addressing requirements  \n * Support different network topologies  \n * Enable custom IP planning | Address prefix management | Configurable address prefixes with manual or automatic management | Use only automatic address prefix assignment |
| * Support different compliance requirements  \n * Enable various security configurations  \n * Provide deployment options | Clean default configurations | Option to clean default security group and ACL rules | Keep default rules |
| * Enable resource organization  \n * Support governance requirements  \n * Implement resource management | Resource groups and tagging | Configurable resource groups and comprehensive tagging support | Use default resource organization |
{: caption="Table 3. Flexibility and customization architecture decisions" caption-side="bottom"}

## Key features
{: #ra-vpc-fully-configurable-features}

The Fully configurable variation provides comprehensive control over:

### Core VPC Infrastructure
- **VPC creation and configuration**: Complete control over VPC settings including classic access and DNS configuration
- **Multi-zone deployment**: Support for deployments across multiple availability zones
- **Address prefix management**: Flexible address prefix configuration for custom IP planning

### Networking Components
- **Subnets**: Create and configure subnets across zones with custom CIDR blocks
- **Network ACLs**: Define custom network access control rules for subnet-level security
- **Security groups**: Configure instance-level firewall rules for application security
- **Public gateways**: Optional internet access configuration per zone

### Advanced Connectivity
- **VPN gateways**: Establish secure site-to-site connections to on-premises environments
- **VPE gateways**: Private connectivity to IBM Cloud services without internet traversal
- **DNS configuration**: Advanced DNS settings including hub-and-spoke DNS sharing

### Enterprise Features
- **Resource management**: Comprehensive resource group and tagging capabilities
- **Compliance support**: Configurable security settings to meet various compliance requirements
- **Integration ready**: Designed as a foundation for additional IBM Cloud services and workloads

<!--
## Compliance
{: #ra-vpc-fully-configurable-compliance}

TODO: Decide whether to include a compliance section, and if so, add that information

_Optional section._ Feedback from users implies that architects want only the high-level compliance items and links off to control details that team members can review. Include the list of control profiles or compliance audits that this architecture meets. For controls, provide "learn more" links to the control library that is published in the IBM Cloud Docs. For audits, provide information about the compliance item.
 -->

<!--
## Next steps
{: #ra-vpc-fully-configurable-next-steps}

TODO: Decide what next steps to list, if any

Optional section. Include links to your deployment guide or next steps to get started with the architecture. -->
