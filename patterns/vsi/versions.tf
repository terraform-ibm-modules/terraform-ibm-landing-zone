##############################################################################
# Terraform Providers
##############################################################################

terraform {
  required_version = ">= 1.3, < 1.6"
  # Pin to the lowest provider version of the range defined in the main module's version.tf to ensure lowest version still works
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.58.1"
    }
    # tflint-ignore: terraform_unused_required_providers
    external = {
      source  = "hashicorp/external"
      version = "2.2.3"
    }
  }
}

##############################################################################
