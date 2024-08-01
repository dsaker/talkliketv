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
    email  = google_service_account.sa_talkliketv.email
    scopes = ["cloud-platform"]
  }

#  provisioner "remote-exec" {
#    when    = "destroy"
#    command = "ansible-playbook playbooks/unregister_rhsm.yml"
#  }
}

# create null resource to run ansible provisioner because we need google compute instance ip before running
resource "null_resource" "ansible-provisioner" {
  // add gcp instance ip line after [talkliketv] in inventory.txt
  // sleep 30 seconds to make sure gcp instance is ready for ssh
  // uncomment first sed for linux, second for mac. replaces CLOUD_HOST_IP in .envrc file
  // run ansible playbook locally
  provisioner "local-exec" {
    command = <<EOT
          sed '/\[talkliketv\]/{n;s/.*/${local.instance_ip}/g;}' ../ansible/inventory.txt > output.file
          mv output.file ../ansible/inventory.txt
          # sed -i 's/^export CLOUD_HOST_IP=.*$/export CLOUD_HOST_IP=34.105.80.183/' .envrc
          sed -i '' -e 's/^export CLOUD_HOST_IP=.*$/export CLOUD_HOST_IP=34.105.80.184/' .envrc
          sleep 30
          ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i '../ansible/inventory.txt' -e 'gcp_public_ip=${google_compute_instance.talkliketv.network_interface.0.access_config.0.nat_ip}' -e 'variable_host=${google_compute_instance.talkliketv.network_interface.0.access_config.0.nat_ip}' ../ansible/playbook.yml
    EOT
  }
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

output "instance_ip" {
  value = google_compute_instance.talkliketv.network_interface.0.access_config.0.nat_ip
}

resource "google_service_account" "sa_talkliketv" {
  account_id   = "talkliketv-service-account-id"
  display_name = "TalkLikeTv Service Account"
}

data "google_iam_policy" "talkliketv" {
  binding {
    role = "roles/cloudtranslate.user"

    members = [
      "serviceAccount:${google_service_account.sa_talkliketv.email}",
    ]
  }
}