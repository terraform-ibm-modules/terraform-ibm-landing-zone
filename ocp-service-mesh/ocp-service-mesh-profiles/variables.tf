##############################################################################
# Input Variables
##############################################################################

variable "control_plane_name" {
  type        = string
  description = "The name to give the control plane. If left null, a default value will be used."
  default     = null
}

variable "control_plane_namespace" {
  type        = string
  description = "Service mesh control plane namespace"
  default     = "istio-system"
}

variable "enrolled_namespaces" {
  type        = list(any)
  description = "Application namespace to enroll into this service mesh control plane"
  default     = []
}

variable "vpc_lb_type" {
  type        = string
  description = "VPC Load Balancer type to provision. Accepts: alb or nlb"
  default     = "alb"

  validation {
    condition     = contains(["alb", "nlb"], var.vpc_lb_type)
    error_message = "Found unsupported value for vpc_lb_type. Must be alb or nlb."
  }
}

variable "additional_sdnlb_ports" {
  type        = list(number)
  description = "Optional list of additional ports to open on the sDNLB transit ingress gateway"
  default     = []
}
