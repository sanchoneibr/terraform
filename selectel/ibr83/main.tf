provider "selectel" {
  token = var.sel_token
}

resource "selectel_vpc_project_v2" "project_1" {
  auto_quotas = true
  name         = var.project_name
  theme = {
    color = "2753E9"
  }
}
