output "instance_ip" {
  value = google_compute_instance.talkliketv.network_interface.0.access_config.0.nat_ip
}

#output "sa_email" {
#  value = module.bucket_module.service_account_email
#}