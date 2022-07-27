##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_providers {
    ibm = {
      source = "IBM-Cloud/ibm"
      # Atracker needs to have the v2 API
      version = ">= 1.43.0"
    }
  }
  required_version = ">=1.0"
  experiments      = [module_variable_optional_attrs]
}

##############################################################################
