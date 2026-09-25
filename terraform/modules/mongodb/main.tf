resource "mongodbatlas_advanced_cluster" "this" {
  project_id   = var.project_id
  name         = var.cluster_name
  cluster_type = "REPLICASET"

  replication_specs = [
    {
      region_configs = [
        {
          electable_specs = {
            instance_size = "M0"
          }

          provider_name         = "TENANT"
          backing_provider_name = "AWS"
          region_name           = var.region
          priority              = 7
        }
      ]
    }
  ]
}

resource "mongodbatlas_database_user" "this" {
  project_id         = var.project_id
  username           = var.database_username
  password           = var.database_password
  auth_database_name = "admin"

  roles {
    role_name     = "readWrite"
    database_name = "petshop"
  }
}

resource "mongodbatlas_project_ip_access_list" "app_servers" {
  project_id = var.project_id
  cidr_block = "${var.nat_eips[0]}/32"
  comment    = "PetShop NAT Gateway"
}