terraform {
  required_version = ">= 0.11.5"

//  backend "gcs" {
//    bucket = "newnationchurch-3239-state"
//    prefix      = "tz-tfsate"
//  }
}

resource "google_storage_bucket" "terraform_state" {
  name     = "${var.gcp_project}-state"
  location = var.gcp_region
  force_destroy = true
  versioning {
    enabled = true
  }
}

provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  credentials = file(var.gcp_auth_file)
  zone        = var.gcp_zone
}

//resource "google_project" "tz-project" {
//  name            = var.project_name
//  project_id      = var.gcp_project
//}
//resource "google_project_service" "project" {
//  project = var.gcp_project
//  service = "iam.googleapis.com"
//}

resource "google_compute_address" "static" {
  name = "vm-public-address"
  project = var.gcp_project
  region = var.gcp_region
  depends_on = [ google_compute_firewall.web-server ]
}
resource "google_compute_instance" "dev" {
  name         = "devserver"
  machine_type = var.linux_instance_type
  zone         = var.gcp_zone
  hostname     = var.hostname
  tags         = ["web-server"]
  boot_disk {
    initialize_params {
      image = var.ubuntu_2004_sku
    }
  }
  network_interface {
    network = google_compute_network.tz_vpc.name
    subnetwork    = google_compute_subnetwork.tz_sub.name
    access_config {
      nat_ip = google_compute_address.static.address
    }
  }
  provisioner "file" {
    source      = "../resources"
    destination = "/home/ubuntu/resources"
    connection {
      host        = google_compute_address.static.address
      type        = "ssh"
      user        = var.user
      private_key = file(var.privatekeypath)
    }
  }
  provisioner "remote-exec" {
    connection {
      host        = google_compute_address.static.address
      type        = "ssh"
      user        = var.user
      timeout     = "500s"
      private_key = file(var.privatekeypath)
    }
    inline = [
      "sudo bash /home/ubuntu/wordpress.sh",
    ]
  }
  depends_on = [ google_compute_firewall.web-server ]
  service_account {
    email  = var.tf_service_account
    scopes = ["compute-ro"]
  }
  metadata = {
    ssh-keys = "${var.user}:${file(var.publickeypath)}"
  }
}

resource "google_project_service" "services" {
  for_each = toset(var.services)
  project                    = var.gcp_project
  service                    = each.key
  disable_dependent_services = false
  disable_on_destroy         = false
//  depends_on = [google_project.tz-project]
}

output "public_ip" {
  value = google_compute_instance.dev.network_interface.0.access_config.0.nat_ip
}
