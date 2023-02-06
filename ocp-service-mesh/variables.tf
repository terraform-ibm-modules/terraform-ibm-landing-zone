##############################################################################
# Input Variables
##############################################################################

variable "ibmcloud_api_key" {
  description = "APIkey that's associated with the account to use, set via environment variable TF_VAR_ibmcloud_api_key"
  type        = string
  sensitive   = true
  default     = null
}

variable "cluster_id" {
  type        = string
  description = "Id of the target IBM Cloud OpenShift Cluster"
}

variable "lb_subnet_ids" {
  type        = list(string)
  description = "List of subnets to attach the ingress gateway's public VPC ALB to. The default for an ALB is to attach it to all subnets"
  default     = []
}

variable "lb_subnet_ids_and_zones" {
  type        = map(string)
  description = "Map of subnets to their zones. Required for configuring an ingress which uses NLBs, which are single-zone"
  default     = {}
}

variable "service_mesh_control_planes" {
  type = list(object({
    name      = string
    namespace = string
    runtime = optional(object({
      pod = optional(object({
        nodeSelector = optional(object({
          name  = string
          value = string
        }))
        tolerations = optional(list(object({
          key    = string
          value  = string
          effect = string
        })))
      }))
    }))
    gateways = optional(object({
      egress = optional(object({
        nodeSelector = optional(object({
          name  = string
          value = string
        }))
        tolerations = optional(list(object({
          key    = string
          value  = string
          effect = string
        })))
        haAntiAffinity = optional(bool)
      }))
      ingress = optional(object({
        nlb = optional(bool)
        nodeSelector = optional(object({
          name  = string
          value = string
        }))
        tolerations = optional(list(object({
          key    = string
          value  = string
          effect = string
        })))
        haAntiAffinity = optional(bool)
        service = optional(object({
          type = optional(string)
          additionalPorts = optional(list(object({
            name       = string
            port       = number
            targetPort = number
            protocol   = string
          })))
          externalTrafficPolicy = optional(string)
          metadata = optional(object({
            annotations = optional(list(object({
              name  = string
              value = string
            })))
            labels = optional(list(object({
              name  = string
              value = string
            })))
          }))
        }))
      }))
      additionalIngress = optional(map(object({
        nlb = optional(bool)
        # sDNLB = optional(object({
        #   createSDNLB        = bool
        #   enableCSEProxy     = bool
        #   cseProxyIstioLabel = optional(string)
        #   cseProxyPort       = optional(number)
        #   vpcServiceCRN      = optional(string)
        #   additionalPorts    = optional(list(number))
        # }))
        nodeSelector = optional(object({
          name  = string
          value = string
        }))
        tolerations = optional(list(object({
          key    = string
          value  = string
          effect = string
        })))
        haAntiAffinity = optional(bool)
        service = optional(object({
          type                  = optional(string)
          externalTrafficPolicy = optional(string)
          metadata = optional(object({
            annotations = optional(list(object({
              name  = string
              value = string
            })))
            labels = optional(list(object({
              name  = string
              value = string
            })))
          }))
        }))
      })))
      additionalEgress = optional(map(object({
        enabled   = optional(bool)
        namespace = optional(string)
        nodeSelector = optional(object({
          name  = string
          value = string
        }))
        tolerations = optional(list(object({
          key    = string
          value  = string
          effect = string
        })))
        haAntiAffinity = optional(bool)
      })))
    }))
    proxy = optional(object({
      accessLogging = optional(object({
        file = optional(object({
          encoding = optional(string)
          format   = optional(string)
        }))
      }))
    }))
    enrolled_namespaces = optional(list(string))
  }))
  description = "Service Mesh control planes"
  default = [
    {
      namespace = "istio-system"
      name      = "basic-with-mtls"
      runtime = {
        pod = {
          nodeSelector = {
            name : "ibm-cloud.kubernetes.io/worker-pool-name"
            value : "default"
          }
        }
      }
      gateways = {
        egress = {
          haAntiAffinity = true
          nodeSelector = {
            name : "ibm-cloud.kubernetes.io/worker-pool-name"
            value : "edge"
          }
          tolerations = [
            {
              key : "dedicated"
              value : "edge"
              effect : "NoExecute"
            }
          ]
        }
        ingress = {
          haAntiAffinity = true
          nodeSelector = {
            name : "ibm-cloud.kubernetes.io/worker-pool-name"
            value : "edge"
          }
          tolerations = [
            {
              key : "dedicated"
              value : "edge"
              effect : "NoExecute"
            }
          ]
          service = {
            type                  = "LoadBalancer"
            externalTrafficPolicy = "Local"
            metadata = {
              annotations = [
                {
                  name  = "service.kubernetes.io/ibm-load-balancer-cloud-provider-ip-type"
                  value = "public"
                }
              ]
            }
          }
        },
        additionalEgress = {
          transit-egress = {
            enabled   = true
            namespace = "istio-system"
            nodeSelector = {
              name  = "ibm-cloud.kubernetes.io/worker-pool-name"
              value = "transit"
            }
            tolerations = [{
              key : "dedicated"
              value : "transit"
              effect : "NoExecute"
            }]
            haAntiAffinity = true
          }
        }
      }
      proxy = {
        accessLogging = {
          file = {
            encoding = "JSON"
            format   = "[%START_TIME%] [%REQ(:AUTHORITY)%] [%BYTES_RECEIVED%] [%BYTES_SENT%] [%DOWNSTREAM_LOCAL_ADDRESS%] [%DOWNSTREAM_LOCAL_ADDRESS%] [%DOWNSTREAM_REMOTE_ADDRESS%] [%DOWNSTREAM_TLS_VERSION%] [%DURATION%] [%REQUEST_DURATION%] [%RESPONSE_DURATION%] [%RESPONSE_TX_DURATION%] [%DYNAMIC_METADATA(istio.mixer:status)%] [%REQ(:METHOD)%] [%REQ(X-ENVOY-ORIGINAL-PATH?:PATH)%] [%PROTOCOL%] [%REQ(X-REQUEST-ID)%] [%REQUESTED_SERVER_NAME%] [%RESPONSE_CODE%] [%RESPONSE_CODE_DETAILS%] [%RESPONSE_FLAGS%] [%ROUTE_NAME%] [%START_TIME%] [%UPSTREAM_CLUSTER%] [%UPSTREAM_HOST%] [%UPSTREAM_LOCAL_ADDRESS%] [%RESP(X-ENVOY-UPSTREAM-SERVICE-TIME)%] [%UPSTREAM_TRANSPORT_FAILURE_REASON%] [%REQ(USER-AGENT)%] [%REQ(X-FORWARDED-FOR)%] [%REQ(X-ENVOY-ATTEMPT-COUNT)%]"
          }
        }
      }
    }
  ]
}

variable "create_ingress_subdomains" {
  type        = bool
  description = "If set to true, the module also registers each istio gateway in an IBM-provided subdomain with associated TLS certificates. See https://cloud.ibm.com/docs/containers?topic=containers-vpc-lbaas#vpc_lb_dns for details."
  default     = false
}

variable "deploy_operators" {
  type        = bool
  description = "Enable installing RedHat Service Mesh Operator)"
  default     = true
}

variable "develop_mode" {
  type        = bool
  description = "If true, output more logs, and reduce some wait periods"
  default     = false
}


##############################################################################
