terraform {
required_version = ">= 0.14.0"
  required_providers {
    openstack = {
      source  = "terraform-provider-openstack/openstack"
      version = "~> 1.43.0"
    }
     selectel = {
      source  = "selectel/selectel"
      version = "~> 3.6.2"
   }
  }

#  backend "s3" {
#    bucket = "terraform-state-apark"
#    region = "ru-moscow"
#    endpoint = "https://obs.ru-moscow-1.hc.sbercloud.ru"
#    force_path_style = true
#    skip_region_validation      = true
#    skip_credentials_validation = true
#  }
}

