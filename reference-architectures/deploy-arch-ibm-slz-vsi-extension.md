---

copyright:
  years: 2023
lastupdated: "2023-12-15"

keywords:

subcollection: deployable-reference-architectures

authors:
  - name: "Vincent Burckhardt"

# The release that the reference architecture describes
version: 5.3.1

# Whether the reference architecture is published to Cloud Docs production.
# When set to false, the file is available only in staging. Default is false.
production: true

# Use if the reference architecture has deployable code.
# Value is the URL to land the user in the IBM Cloud catalog details page
# for the deployable architecture.
# See https://test.cloud.ibm.com/docs/get-coding?topic=get-coding-deploy-button
deployment-url: https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-vsi-ef663980-4c71-4fac-af4f-4a510a9bcf68-global

docs: https://cloud.ibm.com/docs/secure-infrastructure-vpc

image_source: https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/blob/main/reference-architectures/vsi-extension.drawio.svg

related_links:
  - title: "VPC Landing Zone - Standard Variation"
    url: "https://cloud.ibm.com/docs/deployable-reference-architectures?topic=deployable-reference-architectures-vsi-ra"
    description: "A deployable architecture that is based on the IBM Cloud for Financial Services reference and that provides virtual servers in a secure VPC for your workloads."
  - title: "Red Hat OpenShift Container Platform on VPC Landing Zone"
    url: "https://cloud.ibm.com/docs/deployable-reference-architectures?topic=deployable-reference-architectures-ocp-ra"

Please note that the above refined text maintains the same structure and content as the original while correcting various errors in spelling, grammar, and wording. Additionally, the external download links have been updated to ensure consistency and accuracy.
    description: "A deployable architecture that provides virtual servers in a secure VPC for your workloads."

use-case: Cybersecurity
industry: Banking, Financial Sector
compliance: FedRAMP

content-type: reference-architecture

---

{{site.data.keyword.attribute-definition-list}}

# VSI on existing VPC landing zone - Extension
{: #vsi-ext-ra}
{: toc-content-type="reference-architecture"}
{: toc-industry="Banking, Financial Sector"}
{: toc-use-case="Cybersecurity"}
{: toc-compliance="FedRAMP"}
{: toc-version="5.3.1"}

This deployable architecture extends an existing VPC deployable architecture by creating virtual server instances (VSI) in some or all of the subnets of any existing landing zone VPC deployable architecture. The architecture is based on the IBM Cloud for Financial Services reference architecture.

## Architecture Diagram
{: #ra-vsi-ext-architecture-diagram}

![Architecture Diagram for Adding a VSI to a Landing Zone Deployable Architecture](vsi-extension.drawio.svg "Architecture Diagram for Adding a VSI to a Landing Zone Deployable Architecture"){: caption="Figure 1. VSI on Existing Landing Zone - Extension" caption-side="bottom"}{: external download="vsi-extension.drawio.svg"}

## Design Requirements
{: #ra-vsi-ext-design-requirements}

![Design Requirements for VSI on VPC Landing Zone](heat-map-deploy-arch-slz-vsi-extension.svg "Design Requirements"){: caption="Figure 2. Scope of the Design Requirements" caption-side="bottom"}

<!--
TODO: Add the typical use case for the architecture.
The use case might include the motivation for the architecture composition,
business challenge, or target cloud environments.
-->

## Components
{: #ra-vsi-ext-components}

### VPC architecture decisions
{: #ra-vsi-ext-components-arch}

| Requirement | Component | Reasons for choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
| Create virtual server instances to support management | Management virtual server instances | Create a VPC virtual server instance that can be used for management and maintenance of your hosted application. Configure ACL and security group rules to allow access to IBM Cloud services, and workload and management VPCs. | |
| * Demonstrate compliance with control requirements of the IBM Cloud Framework for Financial Services  \n * Set up network for all created services  \n * Isolate network for all created services  \n * Ensure all created services are interconnected | Secure landing zone components | Create a minimum set of required components for a secure landing zone | Create a modified set of required components for a secure landing zone in preset |
{: caption="Table 1. Architecture decisions" caption-side="bottom"}

### Key and password management architecture decisions
{: #ra-vsi-ext-components-arch-key-pw}

| Requirement | Component | Reasons for choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
| * Use public SSH key to access virtual server instances by using SSH | Public SSH key provided by customer | Ask customer to specify the key. Accept the input as secure parameter. | |
{: caption="Table 3. Key and password management architecture decisions" caption-side="bottom"}

<!--
## Compliance
{: #ra-vsi-ext-compliance}

_Optional section._ Feedback from users implies that architects want only the high-level compliance items and links off to control details that team members can review. Include the list of control profiles or compliance audits that this architecture meets. For controls, provide "learn more" links to the control library that is published in the IBM Cloud Docs. For audits, provide information about the compliance item.
-->

## Next steps
{: #ra-vsi-ext-next-steps}

- See the landing zone [deployment guide](https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-overview).
- Read about [IBM Cloud for Financial Services](/docs/framework-financial-services?topic=framework-financial-services-about)
