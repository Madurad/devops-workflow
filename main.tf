terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    bucket      = env("BUCKET_NAME")
    prefix      = "gcp-infra"
  }
}

provider "google" {
  project = var.gcp_project_id
  region  = var.gcp_region
}


# VPC
resource "google_compute_network" "main" {
  name                    = "${var.project_name}-vpc"
  auto_create_subnetworks = false

  routing_mode = "REGIONAL"
}

# Internet Gateway
resource "google_compute_address" "main" {
  name   = "${var.project_name}-igw"
  region = var.gcp_region
}

# Public Subnet
resource "google_compute_subnetwork" "public" {
  count = length(var.public_subnet_cidrs)

  name          = "${var.project_name}-public-subnet-${count.index + 1}"
  ip_cidr_range = var.public_subnet_cidrs[count.index]
  region       = var.gcp_region
  network      = google_compute_network.main.id
}
 
# Private Subnet
resource "google_compute_subnetwork" "private" {
  count = length(var.private_subnet_cidrs)

  name          = "${var.project_name}-private-subnet-${count.index + 1}"
  ip_cidr_range = var.private_subnet_cidrs[count.index]
  region       = var.gcp_region
  network      = google_compute_network.main.id
}

# Route Table for Public Subnets
resource "google_compute_route" "public" {
  name       = "${var.project_name}-public-route"
  network    = google_compute_network.main.id
  dest_range = "0.0.0.0/0"
  next_hop_gateway = "default-internet-gateway"
}

# Security Group
resource "google_compute_firewall" "web" {
  name    = "${var.project_name}-web-fw"
  network = google_compute_network.main.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
}


# Data source for availability zones
data "google_compute_zones" "available" {
  region = var.gcp_region
}