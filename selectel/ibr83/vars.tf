
variable "project_name" {
  default = "test-project"
}

variable "region" {
  default = "ru-7"
}

# Availability Zone
variable "az_zone" {
  default = "ru-7a"
}

variable "sel_token" {
  description = "Secret Key to access Selectel"
  sensitive   = true
}

variable "selectel_account" {
  description = "ID of the Selectel account (contract number) that can found in the Control panel; "
  sensitive   = true
}

variable "user_openstack" {
  description = " OpenStack user associated with the Cloud Platform project;"
  sensitive   = true
}

variable "passwd_openstack" {
  description = " OpenStack user associated with the Cloud Platform project;"
  sensitive   = true
}

# SSH key to access the cloud server
variable "public_key" {
  default = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDAOvBUwlHYO1Dk4Oqu5D021KQQ2yaeqnLCdnRoEPvU5d/sMLzQF4bcfkgC1xO9kv+ZTN42yTxjhLqs8K03Zdn53C1Bm/AjdIK9BGOyRLF2fEL8I2QpqFH2XCACogxO0ZTp0ye0W4r5xZoWf05p9Tyd3NOAEX7hRB/QEBnb0M3k8tJSGnsyhBcx8gmA8gaFxnzgiuEfIsQqo9bYnhEluwWffesYvyzZXBlEdmUASXiCUZJU4RuhCHKCq1uXt25c1XtoJX+lA3OCL8/4dTgQwzJMrSTke1X8SGMytj5W/PnAZvDhbVWHEwZDbpnTbBGLf4kssxsXA9FCwEpBl98thRF8Y+wP2bnbGg2MeBMSSmRtgo2/3KxYFa/K0rhrAWei6veaN8yqGIz1SLI/svszqIuN90CJFqPb4R7HvagSmlbUVEuWMs0TsWODW/cuAXcKI9Tqkz2mQSXUE0euhi2riYmmg7lIkvqo7XRKA2RmiW4d8MLFFz7G5zdJOhDwA7CgmWk= amatskevich@PC069"
}
# Type of the network volume that the server is created from
variable "volume_type_universal" {
  default = "universal.ru-7a"
}

variable "volume_type_basissd" {
  default = "basicssd.ru-7a"
}

# Subnet CIDR
variable "subnet_cidr" {
  default = "10.10.0.0/24"
}