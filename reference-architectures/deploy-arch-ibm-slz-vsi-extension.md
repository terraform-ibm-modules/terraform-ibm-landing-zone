---

copyright:
  years: 2023, 2024
lastupdated: "2024-09-26"

keywords:

subcollection: deployable-reference-architectures

authors:
  - name: "Vincent Burckhardt"

# The release that the reference architecture describes
version: 8.5.0

# Whether the reference architecture is published to Cloud Docs production.
# When set to false, the file is available only in staging. Default is false.
production: true

# Use if the reference architecture has deployable code.
# Value is the URL to land the user in the IBM Cloud catalog details page
# for the deployable architecture.
deployment-url: https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-vsi-ef663980-4c71-4fac-af4f-4a510a9bcf68-global

docs: https://cloud.ibm.com/docs/secure-infrastructure-vpc

image_source: https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/blob/main/reference-architectures/vsi-extension.drawio.svg

related_links:
  - title: "VPC landing zone - Standard variation"
    url: "https://cloud.ibm.com/docs/deployable-reference-architectures?topic=deployable-reference-architectures-vsi-ra"
    description: "A deployable architecture that is based on the IBM Cloud for Financial Services reference and that provides virtual servers in a secure VPC for your workloads."
  - title: "Red Hat OpenShift Container Platform on VPC landing zone"
    url: "https://cloud.ibm.com/docs/deployable-reference-architectures?topic=deployable-reference-architectures-ocp-ra"
    description: "A deployable architecture that provides virtual servers in a secure VPC for your workloads."

use-case: Cybersecurity
industry: Banking,FinancialSector
compliance: FedRAMP

content-type: reference-architecture

---

{{site.data.keyword.attribute-definition-list}}

# Landing zone for applications with virtual servers - Extension
{: #vsi-ext-ra}
{: toc-content-type="reference-architecture"}
{: toc-industry="Banking,FinancialSector"}
{: toc-use-case="Cybersecurity"}
{: toc-compliance="FedRAMP"}
{: toc-version="8.5.0"}

This deployable architecture extends an existing VPC deployable architecture by creating virtual server instances (VSI) in some or all of the subnets of any existing landing zone VPC deployable architecture. The architecture is based on the IBM Cloud for Financial Services reference architecture.

## Architecture diagram
{: #ra-vsi-ext-architecture-diagram}

![Architecture diagram for adding a VSI to a landing zone deployable architecture](vsi-extension.drawio.svg "Architecture diagram for Landing zone for applications with virtual servers deployable architecture"){: caption="Landing zone for applications with virtual servers - Extension" caption-side="bottom"}{: external download="vsi-extension.drawio.svg"}

## Design requirements
{: #ra-vsi-ext-design-requirements}

![Design requirements for Landing zone for applications with virtual servers](heat-map-deploy-arch-slz-vsi-extension.svg "Design requirements"){: caption="Scope of the design requirements" caption-side="bottom"}

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
| Create virtual server instances to support management | Management of virtual server instances | Create a VPC virtual server instance that can be used for management and maintenance of your hosted application. Configure ACL and security group rules to allow access to IBM Cloud services, and workload and management VPCs. | |
| * Demonstrate compliance with control requirements of the IBM Cloud Framework for Financial Services \n * Set up a network for all created services \n * Isolate network for all created services \n * Help ensure all created services are interconnected | Secure landing zone components | Create a minimum set of required components for a secure landing zone | Create a modified set of required components for a secure landing zone in preset |
{: caption="Architecture decisions" caption-side="bottom"}

### Key and password management architecture decisions
{: #ra-vsi-ext-components-arch-key-pw}

| Requirement | Component | Reasons for choice | Alternative choice |
|-------------|-----------|--------------------|--------------------|
| * Use public SSH key to access virtual server instances by using SSH | Public SSH key provided by customer | Ask the customer to specify the key. Accept the input as a secure parameter. | |
{: caption="Key and password management architecture decisions" caption-side="bottom"}

<!--
## Compliance
{: #ra-vsi-ext-compliance}

_Optional section._ Feedback from users implies that architects want only the high-level compliance items and links off to control details that team members can review. Include the list of control profiles or compliance audits that this architecture meets. For controls, provide "learn more" links to the control library that is published in the IBM Cloud Docs. For audits, provide information about the compliance item.
-->

## Next steps
{: #ra-vsi-ext-next-steps}

- Read about [IBM Cloud for Financial Services](/docs/framework-financial-services?topic=framework-financial-services-about)

- To deploy this architecture, understand [Deploying a landing zone deployable architecture](/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-deploy) steps.
