---

copyright:
  years: 2024
lastupdated: "2024-09-26"

keywords:

subcollection: deployable-reference-architectures

authors:
  - name: "Todd Giguere"

# The release that the reference architecture describes
version: 8.5.0

# Whether the reference architecture is published to Cloud Docs production.
# When set to false, the file is available only in staging. Default is false.
production: true

# Use if the reference architecture has deployable code.
# Value is the URL to land the user in the IBM Cloud catalog details page
# for the deployable architecture.
# See https://test.cloud.ibm.com/docs/get-coding?topic=get-coding-deploy-button
deployment-url: https://cloud.ibm.com/catalog/architecture/deploy-arch-ibm-slz-ocp-95fccffc-ae3b-42df-b6d9-80be5914d852-global

docs: https://cloud.ibm.com/docs/secure-infrastructure-vpc

image_source: https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone/blob/main/reference-architectures/roks-quickstart.drawio.svg

related_links:
  - title: "Red Hat OpenShift Container Platform on VPC landing zone"
    url: "https://cloud.ibm.com/docs/secure-infrastructure-vpc?topic=secure-infrastructure-vpc-ocp-ra"
    description: "Red Hat OpenShift Container Platform on VPC landing zone is a deployable architecture solution that is based on the IBM Cloud for Financial Services reference architecture. It creates secure and compliant Red Hat OpenShift Container Platform workload clusters on a Virtual Private Cloud (VPC) network."

use-case: Cybersecurity
industry: Banking,FinancialSector

content-type: reference-architecture

---

{{site.data.keyword.attribute-definition-list}}

# Red Hat OpenShift Container Platform on VPC landing zone - QuickStart variation
{: #roks-ra-qs}
{: toc-content-type="reference-architecture"}
{: toc-industry="Banking,FinancialSector"}
{: toc-use-case="Cybersecurity"}
{: toc-version="8.5.0"}

The QuickStart variation of the Red Hat OpenShift Container Platform on VPC landing zone deployable architecture creates a fully customizable Virtual Private Cloud (VPC) environment in a single region. The solution provides a single Red Hat OpenShift cluster in a secure VPC for your workloads. The QuickStart variation is designed to deploy quickly for demonstration and development.

## Architecture diagram
{: #ra-roks-qs-architecture-diagram}

![Architecture diagram for the QuickStart variation of Red Hat OpenShift Container Platform on VPC landing zone](roks-quickstart.drawio.svg "Architecture diagram of QuickStart variation of Red Hat OpenShift Container Platform on VPC landing zone deployable architecture"){: caption="Figure 1. QuickStart variation of Red Hat OpenShift Container Platform on VPC landing zone" caption-side="bottom"}{: external download="roks-quickstart.drawio.svg"}

## Design concepts
{: #ra-roks-qs-design-concepts}

![Design requirements for Red Hat OpenShift Container Platform on VPC landing zone](heat-map-deploy-arch-slz-roks-quickstart.svg "Design concepts"){: caption="Figure 2. Scope of the design concepts" caption-side="bottom"}

## Requirements
{: #ra-roks-qs-requirements}

The following table outlines the requirements that are addressed in this architecture.

| Aspect | Requirements |
|---|---|
| Compute | Kubernetes cluster with minimal machine size and nodes, suitable for low-cost demonstration and development |
| Storage | Kubernetes cluster registry backup (required) |
| Networking | * Multiple VPCs for network isolation. \n * All public inbound and outbound traffic allowed to VPCs. \n * Administration of cluster allowed from public endpoint and web console. \n * Load balancer for cluster workload services. \n * Outbound internet access from cluster. \n * Private network connection between VPCs. |
| Security | * Encryption of all application data in transit and at rest to protect it from unauthorized disclosure. \n * Storage and management of all encryption keys. \n * Protect cluster administration access through IBM Cloud security protocols. |
| Service Management | Automated deployment of infrastructure with IBM Cloud catalog |
{: caption="Table 1. Requirements" caption-side="bottom"}

## Components
{: #ra-roks-qs-components}

The following table outlines the products or services used in the architecture for each aspect.

| Aspects | Architecture components | How the component is used |
|---|---|---|
| Compute | Red Hat OpenShift Container Platform | Container execution |
| Storage | IBM Cloud Object Storage | Registry backup for Red Hat OpenShift |
| Networking | * VPC Load Balancer \n * Public Gateway \n * Transit Gateway | * Application load balancing for cluster workloads (automatically created by Red Hat OpenShift service for multi-zone cluster) \n * Cluster access to the internet \n * Private network connectivity between management and workload VPCs |
| Security | * IAM \n * Key Protect | * IBM Cloud Identity and Access Management \n * Management of encryption keys used by Red Hat OpenShift Container Platform |
{: caption="Table 2. Components" caption-side="bottom"}
