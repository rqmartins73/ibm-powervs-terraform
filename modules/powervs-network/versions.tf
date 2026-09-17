terraform {
  required_version = ">= 1.5.0, < 2.0.0"

  required_providers {
    ibm = {
      source  = "IBM-Cloud/ibm"
      version = ">= 1.75.0, < 3.0.0"
    }
  }
}
