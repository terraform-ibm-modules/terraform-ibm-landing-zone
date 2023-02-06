##############################################################################
# Input Variables
##############################################################################

variable "label" {
  type        = string
  description = "Value of the app and istio label applied to the transit ingress gateway"
  default     = "ingressgateway-transit"
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
