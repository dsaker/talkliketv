provider "google" {
  project = var.project_id
  region  = var.default_region
}

#terraform {
#  required_providers {                     #### ansible provider
#    ansible = {
#      version = "~> 1.3.0"
#      source  = "ansible/ansible"
#    }
#  }
#}