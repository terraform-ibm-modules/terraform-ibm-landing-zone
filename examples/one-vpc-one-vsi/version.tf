terraform {
  required_version = ">= 1.3, < 1.7"
  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = "1.66.0"
    }
  }
}
