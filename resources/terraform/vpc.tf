#################
# PROJECT
#################
data "google_client_config" "current" {}

#################
# VPC
#################
resource "google_compute_network" "tz_vpc" {
  project   = data.google_client_config.current.project
  name = "tz-vpc"
  auto_create_subnetworks = false
  mtu                     = 1460
}

#################
# SUBNET
#################
resource "google_compute_subnetwork" "tz_sub" {
  project     = data.google_client_config.current.project
  name          = "tz-sub"
  ip_cidr_range = var.network-subnet-cidr
  region        = var.gcp_region
  network       = google_compute_network.tz_vpc.name
  description   = "This is a custom subnet "
  private_ip_google_access = "true"
  log_config {
    aggregation_interval = "INTERVAL_10_MIN"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
  secondary_ip_range {
    range_name    = "subnet-01-secondary-01"
    ip_cidr_range = "192.168.64.0/24"
  }
}
######################
# Firewall
######################
resource "google_compute_firewall" "firewall" {
  project     = data.google_client_config.current.project
  name    = "gritfy-firewall-externalssh"
  network = "default"
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  source_ranges = ["0.0.0.0/0"] # Not So Secure. Limit the Source Range
  target_tags   = ["externalssh"]
}
resource "google_compute_firewall" "web-server" {
  project     = data.google_client_config.current.project  # you can Replace this with your project ID in quotes var.project_id
  name        = "allow-http-rule"
  network     = google_compute_network.tz_vpc.name
  description = "Creates firewall rule targeting tagged instances"
  allow {
    protocol = "tcp"
    ports    = ["80","443"]
  }
  source_ranges = ["0.0.0.0/0"]
  target_tags = ["web-server"]
}

output "project" {
  value = data.google_client_config.current.project
}

