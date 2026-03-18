terraform {
  required_version = ">= 1.4.0"

  required_providers {
    scaleway = {
      source  = "scaleway/scaleway"
      version = "~> 2.0"
    }
  }
}

provider "scaleway" {}

variable "region" {
  description = "Scaleway region to deploy into"
  type        = string
  default     = "fr-par"
}
