variable "gcp_region" {
  description = "GCP region for resources"
  type        = string
  default     = "us-central1"
}

variable "project_name" {
  description = "Name of the project (used for resource naming)"
  type        = string
  default     = "madura-terraform-project"
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "vpc_cidr" {
  description = "CIDR block for VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed for SSH access"
  type        = list(string)
  default     = ["0.0.0.0/0"]  # Change this to your specific IP range for security
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "key_pair_name" {
  description = "Name of AWS key pair for EC2 instances"
  type        = string
  default     = null
}

variable "gcp_project_id" {
  description = "GCP Project ID for resources"
  type        = string
  default     = "my-gcp-project"
  
}

variable "gcp_service_account" {
  description = "GCP Service Account email for resource access"
  type        = string
  default     = "my-gcp-service-account@my-gcp-project.iam.gserviceaccount.com"
}