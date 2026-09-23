output "connection_string" {
  value = format(
    "mongodb+srv://%s:%s@%s/petshop",
    urlencode(var.database_username),
    urlencode(var.database_password),
    trimprefix(
      mongodbatlas_advanced_cluster.this.connection_strings.standard_srv,
      "mongodb+srv://"
    )
  )

  sensitive = true
}