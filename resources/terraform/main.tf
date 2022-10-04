provider "google" {
  project = var.gcp_project
  region  = var.gcp_region
  credentials = file(var.gcp_auth_file)
  zone        = var.gcp_zone
}
//resource "google_project_service" "project" {
//  project = var.gcp_project
//  service = "iam.googleapis.com"
//}
resource "google_project" "tz-project" {
  name            = var.project_name
  project_id      = var.gcp_project
//  billing_account = var.billing_account
}
data "google_client_config" "current" {
}
# create VPC
resource "google_compute_network" "vpc" {
  project   = data.google_client_config.current.project
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = "false"
  routing_mode            = "GLOBAL"
}
# create public subnet
resource "google_compute_subnetwork" "network_subnet" {
  name          = "${var.project_name}-subnet"
  ip_cidr_range = var.network-subnet-cidr
  region        = var.gcp_region
  network       = google_compute_network.vpc.name
  private_ip_google_access = "true"
}
resource "google_compute_firewall" "firewall" {
  project     = data.google_client_config.current.project
  name    = "gritfy-firewall-externalssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80","22","443"]
  }
  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["externalssh"]
}
resource "google_compute_firewall" "webserverrule" {
  name    = "gritfy-webserver"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }
  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["webserver"]
}

# We create a public IP address for our google compute instance to utilize
resource "google_compute_address" "static" {
  name = "vm-public-address"
  project = var.gcp_project
  region = var.gcp_region
  depends_on = [ google_compute_firewall.firewall ]
}
resource "google_compute_instance" "dev" {
  name         = "devserver"
  machine_type = var.linux_instance_type
  zone         = var.gcp_zone
  hostname     = var.hostname
  tags         = ["externalssh","webserver"]
  boot_disk {
    initialize_params {
      image = var.ubuntu_2004_sku
    }
  }
  network_interface {
    network = google_compute_network.vpc.name
    subnetwork    = google_compute_subnetwork.network_subnet.name
    access_config {
      nat_ip = google_compute_address.static.address
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
      "sudo apt-get -y install nginx",
      "sudo nginx -v",
    ]
  }
  # Ensure firewall rule is provisioned before server, so that SSH doesn't fail.
  depends_on = [ google_compute_firewall.firewall, google_compute_firewall.webserverrule ]
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
  depends_on = [google_project.tz-project]
}

//output "public_ip" {
//  value = "${google_compute_instance.dev.network_interface.0.access_config.0.assigned_nat_ip}"
//}
