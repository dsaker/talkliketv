variable "project_id" {
  type = string
}

variable "default_region" {
  type = string
}

variable "gce_ssh_user" {
  type = string
}

variable "gce_ssh_pub_key_file" {
  type = string
}

variable "gce_ssh_private_key_file" {
  type = string
}

variable "talkliketv_machine_type" {
  type = string
}

variable "db_user" {
  default = ""
}

variable "db_password" {
  default = ""
}

variable "db_name" {
  default = ""
}

variable "module_bucket_name" {
  description = "Name of the gcp bucket. Must be unique."
  type        = string
}

variable "module_sa_account_id" {
  description = "Name of the service account id for the bucked."
  type        = string
}
