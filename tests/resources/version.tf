terraform {
  required_version = ">= 1.3.0, <1.6.0"
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = ">= 4.0.4"
    }
  }
}
