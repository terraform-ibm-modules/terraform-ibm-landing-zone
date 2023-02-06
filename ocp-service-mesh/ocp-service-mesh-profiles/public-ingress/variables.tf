##############################################################################
# Input Variables
##############################################################################

variable "label" {
  type        = string
  description = "Value of the app and istio label applied to the ingress gateway"
  default     = "ingressgateway"
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

##############################################################################
