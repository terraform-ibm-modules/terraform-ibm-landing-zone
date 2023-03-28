# Understanding your responsibilities when using Landing Zone Deployable Architecture

In IBM Cloud, the responsibilities for deploying, operating, and securing products are shared between IBM and you, the application provider. It is important for you to understand these responsibilities for every IBM Cloud service that is deployed as part of this Deployable Architecture (DA).

This document walks through the main categories outlined in (https://cloud.ibm.com/docs/overview?topic=overview-shared-responsibilities)[Shared responsibilities for using IBM Cloud products] for the specific case of the Landing Zone Deployable Architecture. 

This document augments and completes (but does not replaces) the documentation on shared responsabilities for each of the provisioned services with specifics to the DA - see [framework-financial-services-shared-responsibilities](https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-shared-responsibilities).

The scope of this document only includes the capabilities surfaced in IBM Cloud Catalog, and does not cover capabilities such as Teleport, Big IP F5 support that are specific to the open-source version of this DA.


## Incident and operations management

Incident and operations management includes tasks such as monitoring, event management, high availability, problem determination, recovery, and full state backup and recovery.

The DA does not provide further support in this area. Incident and operations management tasks are outlines for each provisioned services at https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-shared-responsibilities


## Change management

Includes tasks such as deployment, configuration, upgrades, patching, configuration changes, and deletion.

IBM Responsabilities:
- Provide regular semantic-versioned updates to the DA automation
- Ensure that the DA remains current wrt the financial services specification
- Provide migration path between major releases
- Provide documentation and notices of EoL by major releases.

Customer Responsabilities:
- Apply the provided updates to the DA.
- Apply patches and updates to the compute resources created from the DA. These resource are not updated (unless otherwise indicated) through DA updates
   - OpenShift cluster https://cloud.ibm.com/docs/openshift?topic=openshift-update
   - IKS cluster https://cloud.ibm.com/docs/containers?topic=containers-update
   - VSIs operating system and utilities

## Identity and access management

Includes tasks such as authentication, authorization, access control policies, and approving, granting, and revoking access.

IBM Responsabilities:
- Document the minimal IAM access requirements (least privileges) to execute the DA

Customer Responsabilities:
- Generate necessary secrets (IAM API Key, SSH Key) required as an input to the DA, based on the provided documentation guidance
- Manage generated secrets following secure best practices


## Security and regulation compliance

IBM Responsabilities:
- Provide default configuration that passes goals from a given FsCloud SCC profile version (https://cloud.ibm.com/docs/security-compliance?topic=security-compliance-fs-change-log) - unless otherwise indicated.

Customer Responsabilities:
- Apply any prerequisite, manual steps documented in the DA
- Understand impact of any user-inputed change to the default configuration on security and compliance posture - run SCC compliance check if needed to ensure continuity of compliance posture.

## Disaster recovery

Includes tasks such as providing dependencies on disaster recovery sites, provision disaster recovery environments, data and configuration backup, replicating data and configuration to the disaster recovery environment, and failover on disaster events.

The DA does not provide further support in this area. Refer to the corresponding sections for the provisioned services at https://cloud.ibm.com/docs/framework-financial-services?topic=framework-financial-services-shared-responsibilities