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

# Create a single Compute Engine instance
resource "google_compute_instance" "talkliketv" {
  name         = "talkliketv-vm"
  machine_type = "f1-micro"
  zone         = "us-west1-a"
  tags         = ["ssh"]

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
      # Include this section to give the VM an external IP address
    }
  }

  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = google_service_account.sa_talkliketv.email
    scopes = ["cloud-platform"]
  }
}

resource "google_compute_firewall" "talkliketv_vpc_network_allow_ssh" {
  name    = "talkliketv-vpc-network-allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags = ["ssh"]
  source_ranges = ["0.0.0.0/0"]
}

output "instance_ip" {
  value = google_compute_instance.talkliketv.network_interface[0].access_config.*.nat_ip
}

resource "google_service_account" "sa_talkliketv" {
  account_id = "talkliketv-service-account-id"
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