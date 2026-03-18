locals {
  lb            = scaleway_rdb_instance.ducklake.load_balancer
  postgres_host = length(local.lb) > 0 ? local.lb[0].ip : null
  postgres_port = length(local.lb) > 0 ? local.lb[0].port : null
}

output "ducklake_postgres_host" {
  description = "Hostname of the managed PostgreSQL instance"
  value       = local.postgres_host
}

output "ducklake_postgres_port" {
  description = "Port of the managed PostgreSQL instance"
  value       = local.postgres_port
}

output "s3_bucket_endpoint" {
  description = "S3-compatible endpoint for the DuckLake object storage bucket"
  value       = "https://s3.${var.region}.scw.cloud/${var.s3_bucket_name}"
}

# Scaleway exposes the RDB connection details (host/port) via the load_balancer
# attribute, which is only known after apply. The local_file provider computes
# its content at plan time and can't handle unknown values, so we use
# terraform_data + local-exec instead, which runs after all values are resolved.
resource "terraform_data" "outputs" {
  triggers_replace = [
    local.postgres_host,
    local.postgres_port,
    var.region,
    var.s3_bucket_name,
  ]

  provisioner "local-exec" {
    environment = {
      OUTPUT_JSON = jsonencode({
        ducklake_postgres_host = local.postgres_host
        ducklake_postgres_port = local.postgres_port
        s3_bucket_endpoint     = "https://s3.${var.region}.scw.cloud/${var.s3_bucket_name}"
        s3_data_path           = "s3://${var.s3_bucket_name}"
        s3_region              = var.region
      })
    }
    command = "mkdir -p '${path.module}/../data' && printf '%s' \"$OUTPUT_JSON\" > '${path.module}/../data/outputs.json'"
  }
}
