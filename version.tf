##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      # Atracker needs to have the v2 API
      version = ">= 1.49.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.4.3"
    }
  }
  required_version = ">= 1.0.0"
  experiments      = [module_variable_optional_attrs]
}

##############################################################################
