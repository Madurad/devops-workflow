terraform {
  required_version = ">= 1.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
  backend "gcs" {
    # Configure the GCS backend
    # Bucket name and prefix are provided via GitHub Actions outputs/variables
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
  project                 = var.gcp_project_id
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

resource "google_container_cluster" "primary" {
  name     = "${var.project_name}-k8s-cluster"
  location = var.gcp_region
  project = var.gcp_project_id

  initial_node_count = 1
  
}

resource "google_container_node_pool" "primary_nodes" {
  name       = "${var.project_name}-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.primary.name
  project    = var.gcp_project_id

  node_count = 1

  node_config {
    machine_type = "e2-small"
    disk_size_gb = var.disk_size_gb

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  autoscaling {
    max_node_count = 3
    min_node_count = 1
  }
}