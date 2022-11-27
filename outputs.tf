output "account_id" {
  description = "AWS Account ID"
  value       = var.account_id
}

output "current_id" {
  description = "Your current AWS Account ID"
  value       = var.current_id
}

output "region" {
  description = "AWS region"
  value       = var.region
}

output "current_region" {
  description = "Your current AWS region"
  value       = var.current_region
}

output "engine" {
  description = "RDS Aurora engine"
  value       = aws_rds_cluster.this.engine 
}

output "engine_version" {
  description = "RDS Aurora engine version"
  value       = aws_rds_cluster.this.engine_version
}

output "instance_class" {
  description = "RDS Aurora instance class"
  value       = var.instance_class 
}

output "backup_retention_period" {
  description = "RDS Aurora backup retention period"
  value       = var.backup_retention_period 
}

output "preferred_backup_window" {
  description = "RDS Aurora backup window"
  value       = var.preferred_backup_window 
}

output "storage_encrypted" {
  description = "Specifies whether the DB cluster is encrypted."
  value       = var.storage_encrypted
}

output "deletion_protection" {
  description = "DB instance deletion protection"
  value       = var.deletion_protection
}

output "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  value       = var.auto_minor_version_upgrade
}

output "cluster_identifier" {
  description = "RDS Aurora cluster name"
  value       = aws_rds_cluster.this.cluster_identifier
}

output "db_subnet_group_id" {
  description = "RDS Aurora subnet group id"
  value       = aws_db_subnet_group.this.id
}

output "db_cluster_parameter_group_id" {
  description = "RDS Aurora cluster parameter group id"
  value = aws_rds_cluster_parameter_group.this.id
}

output "db_parameter_group_id" {
  description = "RDS Aurora parameter group id"
  value = aws_db_parameter_group.this.id
}