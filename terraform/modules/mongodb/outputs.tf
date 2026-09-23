output "connection_string" {
  value     = mongodbatlas_advanced_cluster.this.connection_strings.standard_srv
  sensitive = true
}