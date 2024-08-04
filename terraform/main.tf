#module "bucket_module" {
#  source = "./talkliketv-bucket"
#
#  bucket_name = var.module_bucket_name
#  db_user = var.module_db_user
#}

resource "google_compute_address" "static" {
  name = "talkliketv-ipv4-address"
}

resource "google_compute_network" "vpc_network" {
  name                    = "talkliketv-vpc-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

resource "google_compute_subnetwork" "subnetwork_talkliketv" {
  name          = "talkliketv-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}

locals {
  # IP for gcp instance
  instance_ip = google_compute_instance.talkliketv.network_interface.0.access_config.0.nat_ip
}

# Create a single Compute Engine instance
resource "google_compute_instance" "talkliketv" {
  name                      = "talkliketv-vm"
  machine_type              = var.talkliketv_machine_type
  zone                      = "us-west1-a"
  tags                      = ["ssh-talkliketv", "https-talkliketv"]
  allow_stopping_for_update = true
  metadata = {
    ssh-keys = "${var.gce_ssh_user}:${file(var.gce_ssh_pub_key_file)}"
  }

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-minimal-2004-lts"
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnetwork_talkliketv.id

    access_config {
      nat_ip = google_compute_address.static.address
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    # after removing module and adding service account to tfvars uncomment second define statement
    # email  = module.bucket_module.service_account_email
    email = var.sa_email
    scopes = ["cloud-platform"]
  }

#  provisioner "remote-exec" {
#    when    = "destroy"
#    inline = [
#      "pg_dump --dbname=postgres:// -F t >> talktv_db_$(date +%s).sql",
#      "consul join ${aws_instance.web.private_ip}",
#    ]
#  }
}

# create null resource to run ansible provisioner because we need google compute instance ip before running
resource "null_resource" "ansible-provisioner" {
  provisioner "local-exec" {
    command = "chmod +x scripts/ansible-provisioner.sh && scripts/ansible-provisioner.sh"
  }

  depends_on = [local_file.ansible_file]
}

resource "local_file" "ansible_file" {
  content  = templatefile("templates/ansible-provisioner.sh", {
    db_user = var.module_db_user,
    db_password = var.db_password,
    db_name = var.db_name,
    instance_ip = local.instance_ip
  })
  filename = "scripts/ansible-provisioner.sh"
}

resource "google_compute_firewall" "talkliketv_vpc_network_allow_ssh" {
  name    = "talkliketv-vpc-network-allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = ["ssh-talkliketv"]
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "talkliketv_vpc_network_allow_https" {
  name    = "talkliketv-vpc-network-allow-https"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags   = ["https-talkliketv"]
  source_ranges = ["0.0.0.0/0"]
}
