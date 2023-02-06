terraform {
  required_version = ">= 1.3.0"
  required_providers {
    # Use a range in modules
    ibm = {
      source  = "ibm-cloud/ibm"
      version = ">= 1.49.0"
    }
    helm = {
      version = ">= 2.8.0"
    }
    kubernetes = {
      version = ">= 2.16.1"
    }
    time = {
      version = ">= 0.9.1"
    }
    null = {
      version = ">= 3.2.1"
    }
  }
}