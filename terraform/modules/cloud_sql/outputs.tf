output "instance_name" {
  value = google_sql_database_instance.main.name
}

output "connection_name" {
  value = google_sql_database_instance.main.connection_name
}

output "database_name" {
  value = google_sql_database.main.name
}

output "database_user" {
  value = google_sql_user.main.name
}
