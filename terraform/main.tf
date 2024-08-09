#module "bucket_module" {
#  source = "./talkliketv-bucket"
#
#  bucket_name = var.module_bucket_name
#  db_user = var.db_user
#  sa_account_id = var. module_sa_account_id
#}

data "google_storage_bucket_objects" "files" {
  bucket = var.module_bucket_name
}

# store content of initdb.sql in ansible files to run with postgres task
resource "local_file" "initdb_file" {
  content  = data.google_storage_bucket_object_content.initdb.content
  filename = "../ansible/postgres/files/initdb.sql"
}

# get content of last file stored in storage bucket. this will be last object created since
# they are stored in alphabetical order and named with timestamp
data "google_storage_bucket_object_content" "initdb" {
  name   = data.google_storage_bucket_objects.files.bucket_objects[length(data.google_storage_bucket_objects.files.bucket_objects) - 1].name
  bucket = var.module_bucket_name
}

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

# store instance ip in local variable
locals {
  # IP for gcp instance
  instance_ip = google_compute_address.static.address
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

  # service account create in bucket_module with bucket storage and cloud translation permissions added
  service_account {
    # Google recommends custom service accounts that have cloud-platform scope and permissions granted via IAM Roles.
    email  = "${var.module_sa_account_id}@${var.project_id}.iam.gserviceaccount.com"
    scopes = ["cloud-platform"]
  }

  connection {
    type     = "ssh"
    user     = var.gce_ssh_user
    host     = local.instance_ip
    private_key = file(var.gce_ssh_private_key_file)
  }

  provisioner "file" {
    source      = "scripts/on-destroy.sh"
    destination = "/tmp/on-destroy.sh"
  }

  depends_on = [local_file.on_destroy_file]
}

# create null resource to save database state to bucket before destroy in response to this issue:
# https://github.com/hashicorp/terraform/issues/23679
resource "null_resource" "save_db_state" {

  triggers = {
    INSTANCE_ID               = local.instance_ip
    SSH_USER                  = var.gce_ssh_user
    SSH_PRIVATE_KEY_FILE      = var.gce_ssh_private_key_file
  }

  connection {
    type        = "ssh"
    user        = self.triggers.SSH_USER
    host        = self.triggers.INSTANCE_ID
    private_key = file(self.triggers.SSH_PRIVATE_KEY_FILE)
  }

  provisioner "remote-exec" {
    when = destroy
    inline = [
      "chmod +x /tmp/on-destroy.sh",
      "/tmp/on-destroy.sh",
    ]
  }

  depends_on = [google_compute_firewall.talkliketv_vpc_network_allow_ssh]
}

# create null resource to run ansible provisioner because we need google compute instance ip before running
resource "null_resource" "ansible-provisioner" {
  provisioner "local-exec" {
    command = "sleep 60 && chmod +x scripts/ansible-provisioner.sh && scripts/ansible-provisioner.sh"
  }

  depends_on = [local_file.ansible_file, google_compute_instance.talkliketv]
}

resource "local_file" "ansible_file" {
  # pass in shared variables from variables.tfvars into ansible so you don't have to write them twice
  content  = templatefile("templates/ansible-provisioner.sh", {
    db_user = var.db_user,
    db_password = var.db_password,
    db_name = var.db_name,
    instance_ip = local.instance_ip
    ansible_user = var.gce_ssh_user
    ansible_private_key_file = var.gce_ssh_private_key_file
  })
  filename = "scripts/ansible-provisioner.sh"
}

resource "local_file" "on_destroy_file" {
  # bash script that saves db state to bucket when tf state is destroyed
  content  = templatefile("templates/on-destroy.sh", {
    db_user = var.db_user,
    db_password = var.db_password,
    db_name = var.db_name,
    module_bucket_name = var.module_bucket_name
  })
  filename = "scripts/on-destroy.sh"
}

# allow ssh to talkliketv vpc
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

# allow https to talkliketv vpc
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
