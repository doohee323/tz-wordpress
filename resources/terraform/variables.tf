
variable "gcp_region" {
  type        = string
  description = "GCP region"
  default = "us-west2"
}
variable "gcp_zone" {
    type = string
    default = "us-west2-a"
}
variable "gcp_project" {
    type = string
    default = "extreme-signer-364421"
}
variable "project_name" {
    type = string
    default = "newnationchurch"
}
variable "billing_account" {
    type = string
    default = "012435-FAD082-A14F0C"
}
variable "user" {
    type = string
    default = "ubuntu"
}
variable "tf_service_account" {
    type = string
    default = "terraform-account@extreme-signer-364421.iam.gserviceaccount.com"
}
variable "privatekeypath" {
    type = string
    default = "newnationchurch-323"
}
variable "publickeypath" {
    type = string
    default = "newnationchurch-323.pub"
}
variable "network-subnet-cidr" {
  type        = string
  description = "The CIDR for the network subnet"
}
variable "ubuntu_2004_sku" {
  type        = string
  description = "SKU for Ubuntu 20.04 LTS"
  default     = "ubuntu-os-cloud/ubuntu-2004-lts"
}
variable "linux_instance_type" {
  type        = string
  description = "VM instance type for Linux Server"
  default     = "f1-micro"
}
variable "gcp_auth_file" {
  type        = string
  description = "GCP authentication file"
  default     = "../google-key.json"
}
variable "app_domain" {
  type        = string
  default     = "new-nation.church"
}
variable "hostname" {
  type        = string
  default     = "newnationchurch.new-nation.church"
}
variable services {
  type        = list
  default     = [
    "serviceusage.googleapis.com",
    "iamcredentials.googleapis.com",
    "cloudresourcemanager.googleapis.com"
  ]
}


