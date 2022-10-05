# IBM Secure Landing Zone for Mixed Pattern

## Artchitecture Diagram

<img src="../images/patterns/mixed-pattern.png">

## Configured Components and Services

The following components are configured through automation:

## Configured Components and Services
----------------------------------------------------------------
Following common services are created:

- Resource Groups
- Access Groups
- Transit Gateway

| Multi-Zone Region (MZR) Management| Multi-Zone Region (MZR) Workload |
| --------------------------------- |--------------------------------- |
|Management Access Group            |Workload Access Group |
|Management KMS Key                 | Workload KMS Key |
|Management COS Instance and COS buckets | Workload COS Instance and COS buckets |
|Management COS Authorization for HPCS/KeyPorotect | Workload COS Authorization for HPCS/KeyPorotect |
|Management Flow Log, Flow log COS buckets and authorization | Workoad Flow Log, Flow log COS buckets and authorization |
|Management VPC | Workload VPC |
|Management VPC VSI | Workload OpenShift cluster |
|Management VPC VSI encryption authorization | Workload Kubernetes encryption authorization |
|Management VPC VSI SSH module | Workload Subnets for OCP cluster, VPE and VPN resources |
|Management Subnets for VSI, VPE and VPN resources | Workload VPE Gateway (for COS) |
|Management VPE Gateway (for COS) | Workload VPE Gateway (for Container Registry) |
|Management VPE Gateway (for Container Registry) |   |
