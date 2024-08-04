data "google_iam_policy" "talkliketv_bucket" {

  binding {
    role = "roles/storage.objectAdmin"

    members = [
      "serviceAccount:${google_service_account.sa_talkliketv.email}",
      "user:${data.google_client_openid_userinfo.me.email}",
    ]
  }

  binding {
    role = "roles/storage.legacyObjectOwner"

    members = [
      "serviceAccount:${google_service_account.sa_talkliketv.email}",
      "user:${data.google_client_openid_userinfo.me.email}",
    ]
  }

  binding {
    role = "roles/storage.admin"

    members = [
      "serviceAccount:${google_service_account.sa_talkliketv.email}",
      "user:${data.google_client_openid_userinfo.me.email}",
    ]
  }
}

data "google_client_openid_userinfo" "me" {
}

resource "google_storage_bucket_iam_policy" "policy" {
  bucket = google_storage_bucket.talkliketv_bucket.name
  policy_data = data.google_iam_policy.talkliketv_bucket.policy_data
  lifecycle {
    prevent_destroy = true
  }
}

# Create new storage bucket in the US
# location with Standard Storage
resource "google_storage_bucket" "talkliketv_bucket" {
  name          = var.bucket_name
  location      = "US"
  storage_class = "STANDARD"
  uniform_bucket_level_access = true

  versioning {
    enabled = true
  }

  lifecycle_rule {
    action {
      type = "Delete"
    }
    condition {
      num_newer_versions = 3
      no_age = true
    }
  }

  lifecycle {
    prevent_destroy = true
  }
}

resource "local_file" "init_file" {
  content  = templatefile("templates/initdb.sql", { db_user = var.db_user})
  filename = "../ansible/postgres/files/initdb.sql"
}

resource "google_service_account" "sa_talkliketv" {
  account_id   = var.sa_account_id
  display_name = "TalkLikeTv Service Account"

  lifecycle {
    prevent_destroy = true
  }
}

data "google_iam_policy" "talkliketv" {
  binding {
    role = "roles/cloudtranslate.user"

    members = [
      "serviceAccount:${google_service_account.sa_talkliketv.email}",
    ]
  }
}
