resource "google_sql_database_instance" "main" {
  name             = "${var.environment}-mhcet-db"
  database_version = "POSTGRES_16"
  region           = var.region

  settings {
    tier              = var.tier
    availability_type = var.availability_type
    disk_size         = var.disk_size

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = var.point_in_time_recovery_enabled
    }

    ip_configuration {
      ipv4_enabled = true
    }
  }

  deletion_protection = var.deletion_protection
}

resource "google_sql_database" "main" {
  name     = var.database_name
  instance = google_sql_database_instance.main.name
}

resource "google_sql_user" "main" {
  name     = var.database_user
  instance = google_sql_database_instance.main.name
  password = var.database_password
}
