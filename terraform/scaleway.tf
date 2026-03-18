variable "postgres_db_password" {
  description = "Password for the ducklake PostgreSQL user (8-128 chars, must include uppercase, lowercase, digit, and special character)"
  type        = string
  sensitive   = true

  validation {
    condition = (
      length(var.postgres_db_password) >= 8 &&
      length(var.postgres_db_password) <= 128 &&
      can(regex("[0-9]", var.postgres_db_password)) &&
      can(regex("[A-Z]", var.postgres_db_password)) &&
      can(regex("[a-z]", var.postgres_db_password)) &&
      can(regex("[^a-zA-Z0-9]", var.postgres_db_password))
    )
    error_message = "Password must be 8-128 characters and contain at least one digit, uppercase letter, lowercase letter, and special character."
  }
}

resource "scaleway_rdb_instance" "ducklake" {
  name           = "ducklake"
  node_type      = "db-dev-s"
  engine         = "PostgreSQL-16"
  is_ha_cluster  = false
  disable_backup = true
  region         = var.region
}

resource "scaleway_rdb_database" "ducklake" {
  instance_id = scaleway_rdb_instance.ducklake.id
  name        = "ducklake_catalog"
  region      = var.region
}

resource "scaleway_rdb_user" "ducklake" {
  instance_id = scaleway_rdb_instance.ducklake.id
  name        = "ducklake"
  password    = var.postgres_db_password
  region      = var.region
}

resource "scaleway_rdb_privilege" "ducklake" {
  instance_id   = scaleway_rdb_instance.ducklake.id
  user_name     = scaleway_rdb_user.ducklake.name
  database_name = scaleway_rdb_database.ducklake.name
  permission    = "all"
  region        = var.region
}

resource "scaleway_rdb_acl" "ducklake" {
  instance_id = scaleway_rdb_instance.ducklake.id
  region      = var.region

  acl_rules {
    ip          = "0.0.0.0/0"
    description = "Allow all"
  }
}
