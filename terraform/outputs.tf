output "instance_ip" {
  value = google_compute_instance.talkliketv.network_interface.0.access_config.0.nat_ip
}
#
#output "db_file_name" {
#  value = data.google_storage_bucket_objects.files.bucket_objects[local.google_object_num].name
#}