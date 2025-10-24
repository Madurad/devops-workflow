output "vpc_id" {
  description = "ID of the VPC"
  value       = google_compute_network.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = google_compute_network.main.gateway_ipv4
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = google_compute_address.main.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = google_compute_subnetwork.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = google_compute_subnetwork.private[*].id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = google_compute_route.public[*].id
}

output "web_security_group_id" {
  description = "ID of the web security group"
  value       = google_compute_firewall.web.id
}

output "availability_zones" {
  description = "List of availability zones used"
  value       = data.google_compute_zones.available.names
}