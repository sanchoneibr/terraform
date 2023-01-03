
variable "project_name" {
  default = "test-project"
}

variable "region" {
  default = "nl-1"
}

variable "sel_token" {
  description = "Secret Key to access Selectel"
  sensitive   = true
}

# SSH key to access the cloud server
variable "public_key" {
  default = "key_value"
}
# Type of the network volume that the server is created from
variable "volume_type" {
  default = "universal.nl-1a"
}
# Subnet CIDR
variable "subnet_cidr" {
  default = "10.10.0.0/24"
}