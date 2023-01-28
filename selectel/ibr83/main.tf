provider "selectel" {
  token = var.sel_token
}

resource "selectel_vpc_project_v2" "project_1" {
  auto_quotas = true
  name         = var.project_name
}

resource "selectel_vpc_user_v2" "user_1" {
  name = var.user_openstack
  password = var.passwd_openstack
  enabled  = true
}

resource "selectel_vpc_role_v2" "role_tf_user_1" {
  project_id = "${selectel_vpc_project_v2.project_1.id}"
  user_id    = "${selectel_vpc_user_v2.user_1.id}"
}


provider "openstack" {
  auth_url    = "https://api.selvpc.ru/identity/v3"
  domain_name = var.selectel_account
  tenant_id = "${selectel_vpc_project_v2.project_1.id}"
  user_name   = var.user_openstack
  password    = var.passwd_openstack
  region      = var.region
}

# Creating the SSH key
resource "openstack_compute_keypair_v2" "key_tf" {
  name       = "key_tf"
  region     = var.region
  public_key = var.public_key
  depends_on = [
    selectel_vpc_role_v2.role_tf_user_1
  ]
}

# Request external-network ID by name
data "openstack_networking_network_v2" "external_net" {
  name = "external-network"
  depends_on = [
    selectel_vpc_role_v2.role_tf_user_1
  ]
}

# Creating a router
resource "openstack_networking_router_v2" "router_tf" {
  name                = "router_tf"
  external_network_id = data.openstack_networking_network_v2.external_net.id
  depends_on = [
    selectel_vpc_role_v2.role_tf_user_1
  ]
}

# Creating a network
resource "openstack_networking_network_v2" "network_tf" {
  name = "network_tf"
  depends_on = [
    selectel_vpc_role_v2.role_tf_user_1
  ]
}

# Creating a subnet
resource "openstack_networking_subnet_v2" "subnet_tf" {
  network_id = openstack_networking_network_v2.network_tf.id
  name       = "subnet_tf"
  cidr       = var.subnet_cidr
  dns_nameservers = [
    "8.8.8.8",
    "77.88.8.8"
  ]
}

# Connecting the router to the subnet
resource "openstack_networking_router_interface_v2" "router_interface_tf" {
  router_id = openstack_networking_router_v2.router_tf.id
  subnet_id = openstack_networking_subnet_v2.subnet_tf.id
  depends_on = [
    selectel_vpc_role_v2.role_tf_user_1
  ]
}


# Searching for the image ID (that the server will be created from) by its name
data "openstack_images_image_v2" "ubuntu_image" {
  most_recent = true
  visibility  = "public"
  name        = "Ubuntu 20.04 LTS 64-bit"
  depends_on = [
    selectel_vpc_role_v2.role_tf_user_1
  ]
}

data "openstack_images_image_v2" "ubuntu_22_image" {
  most_recent = true
  visibility  = "public"
  name        = "Ubuntu 22.04 LTS 64-bit"
  depends_on = [
    selectel_vpc_role_v2.role_tf_user_1
  ]
}

data "openstack_images_image_v2" "oracle_image" {
  most_recent = true
  visibility  = "public"
  name        = "Oracle Linux 8 64-bit"
  depends_on = [
    selectel_vpc_role_v2.role_tf_user_1
  ]
}


data "openstack_images_image_v2" "centos_image" {
  most_recent = true
  visibility  = "public"
  name        = "CentOS 7 Minimal 64-bit"
  depends_on = [
    selectel_vpc_role_v2.role_tf_user_1
  ]
}


# Creating a unique flavor name
resource "random_string" "random_name_server" {
  length  = 16
  special = false
}

# Creating a server configuration with 1 vCPU and 1 GB RAM
# Parameter  disk = 0  makes the network volume a boot one
resource "openstack_compute_flavor_v2" "flavor_server" {
  name      = "server-${random_string.random_name_server.result}-client"
  ram       = "1024"
  vcpus     = "1"
  disk      = "0"
  is_public = "false"
  depends_on = [
    selectel_vpc_role_v2.role_tf_user_1
  ]
}

# Creating a 5 GB network boot volume from the image
resource "openstack_blockstorage_volume_v3" "volume_server" {
  name                 = "server-${random_string.random_name_server.result}"
  size                 = "60"
  image_id             = data.openstack_images_image_v2.ubuntu_22_image.id
  volume_type          = var.volume_type_basissd
  availability_zone    = var.az_zone
  enable_online_resize = true

  lifecycle {
    ignore_changes = [image_id]
  }
}

#resource "openstack_blockstorage_volume_v2" "volume_1" {
#  name = "volume_1"
#  size = 200
#  volume_type          = var.volume_type
#  availability_zone    = var.az_zone
#}

# Creating a server
resource "openstack_compute_instance_v2" "volume_server_k8s1" {
  name              = "server_k8s1"
  flavor_id         = 9024
#  openstack_compute_flavor_v2.flavor_server.id
  key_pair          = openstack_compute_keypair_v2.key_tf.id
  availability_zone = var.az_zone
  network {
    uuid = openstack_networking_network_v2.network_tf.id
    fixed_ip_v4 = "10.10.0.21"
  }
  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_server.id
    source_type      = "volume"
    destination_type      = "volume"
    boot_index       = 0
  }
   
#  block_device {
#    uuid                  = "${openstack_blockstorage_volume_v2.volume_1.id}"
#    source_type           = "volume"
#    destination_type      = "volume"
#    boot_index            = 1
#    delete_on_termination = true
#  }

  vendor_options {
    ignore_resize_confirmation = true
  }
  lifecycle {
    ignore_changes = [image_id]
  }
}


resource "openstack_blockstorage_volume_v3" "volume_server_k8s2" {
  name                 = "server-${random_string.random_name_server.result}"
  size                 = "60"
  image_id             = data.openstack_images_image_v2.ubuntu_22_image.id
  volume_type          = var.volume_type_basissd
  availability_zone    = var.az_zone
  enable_online_resize = true

  lifecycle {
    ignore_changes = [image_id]
  }
}

# Creating a server
resource "openstack_compute_instance_v2" "server_k8s2" {
  name              = "server_k8s2"
  flavor_id         = 9024
#  openstack_compute_flavor_v2.flavor_server.id
  key_pair          = openstack_compute_keypair_v2.key_tf.id
  availability_zone = var.az_zone
  network {
    uuid = openstack_networking_network_v2.network_tf.id
  }
  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_server_k8s2.id
    source_type      = "volume"
    destination_type      = "volume"
    boot_index       = 0
  }
  
#  block_device {
#    uuid                  = "${openstack_blockstorage_volume_v2.volume_1.id}"
#    source_type           = "volume"
#    destination_type      = "volume"
#    boot_index            = 1
#    delete_on_termination = true
#  }

  vendor_options {
    ignore_resize_confirmation = true
  }
  lifecycle {
    ignore_changes = [image_id]
  }
}


resource "openstack_blockstorage_volume_v3" "volume_client" {
  name                 = "server-${random_string.random_name_server.result}-client"
  size                 = "10"
  image_id             = data.openstack_images_image_v2.ubuntu_image.id
  volume_type          = var.volume_type_basissd
  availability_zone    = var.az_zone
  enable_online_resize = true

  lifecycle {
    ignore_changes = [image_id]
  }
}

resource "openstack_compute_instance_v2" "client_image" {
  name              = "server_client"
  flavor_id         = openstack_compute_flavor_v2.flavor_server.id
  key_pair          = openstack_compute_keypair_v2.key_tf.id
  availability_zone = var.az_zone
  network {
    uuid = openstack_networking_network_v2.network_tf.id
  }
  block_device {
    uuid             = openstack_blockstorage_volume_v3.volume_client.id
    source_type      = "volume"
    destination_type      = "volume"
    boot_index       = 0
  }
  
#  block_device {
#    uuid                  = "${openstack_blockstorage_volume_v2.volume_1.id}"
#    source_type           = "volume"
#    destination_type      = "volume"
#    boot_index            = 1
#    delete_on_termination = true
#  }

  vendor_options {
    ignore_resize_confirmation = true
  }
  lifecycle {
    ignore_changes = [image_id]
  }
}

# Creating a floating IP
resource "openstack_networking_floatingip_v2" "fip_tf" {
  pool = "external-network"
}

# Associating the floating IP to the server
resource "openstack_compute_floatingip_associate_v2" "fip_tf" {
  floating_ip = openstack_networking_floatingip_v2.fip_tf.address
  instance_id = openstack_compute_instance_v2.client_image.id
}
