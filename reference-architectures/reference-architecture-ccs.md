---

copyright:
  years: 2024
lastupdated: "2024-06-12"

subcollection: security-services

authors:
- name: Dharmesh Bhakta
  email: bhakta@ibm.com

# The release that the reference architecture describes
version: 1.0

# Use if the reference architecture has deployable code.
# Value is the URL to land the user in the IBM Cloud catalog details page for the deployable architecture.
# See https://test.cloud.ibm.com/docs/get-coding?topic=get-coding-deploy-button
deployment-url: <url>

use-case:
  - CloudSecurity
  - KeyManagement
  - CloudSecurityAndCompliance
  - DataCompliance
  - Governance
  - GRC

industry: SoftwareAndPlatformApplications, Technology, Banking, FinancialSector

compliance: CIS Benchmarks

docs: https://cloud.ibm.com/docs/<subsection>

content-type: reference-architecture

production: false

---
<!--
The following line inserts all the attribute definitions. Don't delete.
-->
{{site.data.keyword.attribute-definition-list}}

<!--
Don't include "reference architecture" in the following title.
Specify a title based on a use case. If the architecture has a module
or tile in the IBM Cloud catalog, match the title to the catalog. See
https://test.cloud.ibm.com/docs/solution-as-code?topic=solution-as-code-naming-guidance.
-->

# Core Security Services Stack on IBM Cloud
{: #genai-pattern}
{: toc-content-type="reference-architecture"}
{: toc-version="1.0"}

<!--
The IDs, such as {: #title-id} are required for publishing this reference architecture in IBM Cloud Docs. Set unique IDs for each heading. Also include
the toc attributes on the H1, repeating the values from the YAML header.
 -->

This reference architecture summarizes deployment and the best practices for setting of core security sercices and its associated dependency on IBM Cloud. IBM Cloud's core security services are crucial for ensuring robust security and compliance for cloud-based applications and data. Primary goal is to provide framework for secure and compliant IBM Cloud Workloads.

Here’s a brief overview of each service:

Key Protect: This service provides a secure and scalable way to manage encryption keys for your cloud applications. It ensures that sensitive data is protected by managing and safeguarding cryptographic keys, facilitating compliance with industry standards and regulatory requirements. 

Secrets Manager: This service helps in securely storing and managing sensitive information such as API keys, credentials, and certificates. By centralizing secret management, it reduces the risk of exposure and simplifies the process of accessing and rotating secrets, thereby enhancing security posture.

Security and Compliance Center: This platform offers a comprehensive suite of tools to assess, monitor, and maintain the security and compliance of your cloud environment. It provides insights and controls to help organizations meet regulatory requirements, adhere to best practices, and protect against threats.

IBM Cloud Security and Compliance Center Workload Protection: This service offers functionality to protect workloads, get deep cloud and container visibility, posture management (compliance, benchmarks, CIEM), vulnerability scanning, forensics, and threat detection and blocking.

This reference architecture showcases how these services form a foundational security layer that enhances data protection, simplifies compliance, and strengthens overall cloud security for any workload in IBM Cloud. 

## Architecture diagram
{: #architecture-diagram}

The below diagram represents the architecture for Core Security Services on IBM cloud and reuses the [best practices](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-about) for IBM Cloud for Financial Services.

![Architecture.](core-security-services-architecture.svg "Architecture"){: caption="Figure 1. Reference Architecture" caption-side="bottom"}

The architecture is anchored by three fundamental services: Key Protect, Secrets Manager, and IBM Cloud Security Services and Workload Protection. These services provide integration endpoints for any customer workload hosted on IBM Cloud.

1. Key Protect

Key Protect is responsible for centrally managing the lifecycle of encryption keys used by IBM Cloud Object Storage (COS) buckets, Secrets Manager, and event notification resources. Additionally, it can manage encryption keys for any customer workload requiring protection.

2. Secrets Manager

Secrets Manager securely stores and manages sensitive information, including API keys, credentials, and certificates. It utilizes encryption keys from Key Protect to encrypt sensitive data and to seal/unseal vaults holding the secrets. It is preconfigured to send events to the Event Notifications service, allowing customers to set up email or SMS notifications. Moreover, it is automatically configured to forward all API logs to the customer's logging instance.

3. Security Compliance Center

The Security Compliance Center instance is preconfigured to scan all resources provisioned by the reference architecture. It can be expanded to accommodate the unique workloads of customers.


Cloud Object Storage (COS) buckets are set up to receive logs from Logging and Alerting Services. Each bucket is configured to encrypt data at rest using encryption keys managed by Key Protect.

## Design concepts
{: #design-concepts}

- Storage: Backup, Archive
- Networking: Cloud native contectivity
- Security: Data Security, Identity & Access, Application Security, Threat Detection and Response, Infrastructure & Endpoints, Governance, Risk & Compliance
- Resiliency: High Availability
- Service Management: Monitoring, Logging, Auditing / tracking, Automated Deployment

<br>

![heatmap](heat-map-ccs.svg "Current diagram"){: caption="Figure 2. Architecture design scope" caption-side="bottom"}

## Requirements
{: #requirements}

The following table outlines the requirements that are addressed in this architecture.

| Aspect | Requirements |
| -------------- | -------------- |
| Networking         | Provide secure, encrypted connectivity to the cloud’s private network for management purposes. |
| Security           | Encrypt all application data in transit and at rest to protect from unauthorized disclosure. \n Encrypt all security data (operational and audit logs) to protect from unauthorized disclosure. \n Encrypt all data using customer managed keys to meet regulatory compliance requirements for additional security and customer control. \n Protect secrets through their entire lifecycle and secure them using access control measures. |
| Resiliency         | Support application availability targets and business continuity policies. \n Ensure availability of the application in the event of planned and unplanned outages. \n Backup application data to enable recovery in the event of unplanned outages. \n Provide highly available storage for security data (logs) and backup data. |
| Service Management | Monitor system and application health metrics and logs to detect issues that might impact the availability of the application. \n Generate alerts/notifications about issues that might impact the availability of applications to trigger appropriate responses to minimize down time. \n Monitor audit logs to track changes and detect potential security problems. \n Provide a mechanism to identify and send notifications about issues found in audit logs. |
{: caption="Table 1. Requirements" caption-side="bottom"}


## Components
{: #components}

The following table outlines the products or services used in the architecture for each aspect.

| Aspects | Architecture components | How the component is used |
| -------------- | -------------- | -------------- |
| Storage | [Cloud Object Storage](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-about-cloud-object-storage) | Web app static content, backups, logs (application, operational, and audit logs) |
| Networking | [Virtual Private Endpoint (VPE)](https://cloud.ibm.com/docs/vpc?topic=vpc-about-vpe) | For private network access to Cloud Services, e.g., Key Protect, Secrets Manaegr, SCC, etc. |
| Security | [IAM](https://cloud.ibm.com/docs/account?topic=account-cloudaccess) | IBM Cloud Identity & Access Management |
|  | [Key Protect](https://cloud.ibm.com/docs/key-protect?topic=key-protect-about) | A full-service encryption solution that allows data to be secured and stored in IBM Cloud |
|  | [Secrets Manager](https://cloud.ibm.com/docs/secrets-manager?topic=secrets-manager-getting-started#getting-started) | Certificate and Secrets Management |
|  | [Security and Compliance Center (SCC)](https://cloud.ibm.com/docs/security-compliance?topic=security-compliance-getting-started) | Implement controls for secure data and workload deployments, and assess security and compliance posture |
|  | [Security and Compliance Center Workload Protection  ](https://cloud.ibm.com/docs/workload-protection?topic=workload-protection-getting-started) | |
| Service Management | [IBM Cloud Monitoring](https://cloud.ibm.com/docs/monitoring?topic=monitoring-about-monitor) | Apps and operational monitoring |
|  | [IBM Log Analysis](https://cloud.ibm.com/docs/log-analysis?topic=log-analysis-getting-started) | Apps and operational logs |
|  | [Activity Tracker Event Routing](https://cloud.ibm.com/docs/activity-tracker?topic=activity-tracker-getting-started) | Audit logs |
{: caption="Table 2. Components" caption-side="bottom"}


## Compliance
{: #compliance}

- Ensure Cloud Object Storage encryption is enabled with BYOK
- Ensure Activity Tracker data is encrypted at rest
- Ensure Activity Tracker trails are integrated with LogDNA Logs
- Ensure IBM Key Protect has automated rotation for customer managed keys enabled
- Ensure the IBM Key Protect service has high availability

**Security and Compliance Center (SCC)** <br>
This reference architecture utilizes the Security and Compliance Center (SCC) which defines policy as code, implements controls for secure data and workload deployments and assess security and compliance posture. For this reference architecture the CIS IBM Cloud Foundations Benchmark is used. A profile is a grouping of controls that can be evaluated for compliance.
