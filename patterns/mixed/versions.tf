##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_version = ">= 1.3, < 1.7"
  # renovate is set up to keep provider version at the latest for all DA solutions
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.64.0"
    }
    external = {
      source  = "hashicorp/external"
      version = "2.3.3"
    }
  }
}

##############################################################################
