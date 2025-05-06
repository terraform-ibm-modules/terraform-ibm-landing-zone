##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_version = ">= 1.3"
  # Use "greater than or equal to" range for root level modules
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.78.0, < 2.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3, < 4.0.0"
    }
    time = {
      source  = "hashicorp/time"
      version = ">= 0.9.1, < 1.0.0"
    }
  }
}

##############################################################################
