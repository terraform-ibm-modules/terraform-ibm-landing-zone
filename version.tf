##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_version = ">= 1.3, < 1.6"
  # Use "greater than or equal to" range for root level modules
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.58.1"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}

##############################################################################
