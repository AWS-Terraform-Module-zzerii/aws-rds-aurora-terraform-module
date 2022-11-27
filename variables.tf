variable "region" {
  description = "AWS Region"
  type        = string
}

variable "current_region" {
  description = "AWS Region"
  type        = string
}

variable "account_id" {
  description = "List of Allowed AWS account IDs"
  type        = string
}

variable "current_id" {
  description = "current id"
  type        = string
}

variable "prefix" {
  description = "prefix for aws resources and tags"
  type        = string
}

variable "cluster_name" {
  description = "RDS Aurora Cluster Name"
  type        = string
}

variable "engine" {
  description = "RDS Aurora Engine Name"
  type        = string
}

variable "engine_version" {
  description = "RDS Aurora Engine Version"
  type        = string
}

variable "engine_mode" {
  description = "RDS Aurora Engine Mode"
  type        = string
}

variable "azs" {
  description = "Availability Zone List"
  type        = list(string)
}

variable "vpc_id" {
  description = "vpc id"
  type        = string
}

variable "database_name" {
  description = "RDS Aurora Database Name"
  type        = string
}

variable "master_username" {
  description = "RDS Aurora Master User Name"
  type        = string
}

variable "master_password" {
  description = "RDS Aurora Master User Password(cli only)"
  type        = string
}

variable "port" {
  description = "RDS Aurora PostgreSQL Port"
  type        = string
}

variable "backup_retention_period" {
  description = "RDS Aurora Database Backup Period"
  type        = string
}

variable "preferred_backup_window" {
  description = "RDS Aurora Database Backup Start Time for Daily"
  type        = string
}

variable "preferred_maintenance_window" {
  description = "RDS Aurora Maintenance Window"
  type        = string
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window."
  type        = bool
}

variable "enabled_cloudwatch_logs_exports" {
  description = "Set of log types to export to cloudwatch."
  type        = list(string)
}

variable "subnet_ids" {
  description = "Subnet list for RDS Aurora"
  type        = list(string)
}

variable "vpc_security_group_ids" {
  description = "List of VPC security groups to associate with the Cluster"
  type        = list(string)
}

variable "replica_count" {
  description = "RDS Aurora Multi AZ"
  type        = string
}

variable "instance_class" {
  description = "RDS Aurora Intance Type"
  type        = string
}

variable "deletion_protection" {
  description = "RDS Aurora Deletion Protection"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "RDS Aurora Final Snapshot Skip"
  type        = bool
}

variable "kms_key_id" {
  description = "kms key"
  type        = string
}

variable "storage_encrypted" {
  description = "aurora rds encrypted using kms"
  type        = bool
  default     = true
}

variable "cluster_parameter_group_name" {
  description = "aurora rds cluster parameter group name"
  type        = string
}

variable "cluster_parameter_group_family" {
  description = "aurora rds cluster parameter group family"
  type        = string
}

variable "cluster_parameter" {
  description = "aurora rds cluster parameter map"
  type        = map(string)
}

variable "parameter_group_name" {
  description = "aurora rds parameter group name"
  type        = string
}

variable "parameter_group_family" {
  description = "aurora rds parameter group family"
  type        = string
}

variable "parameter" {
  description = "aurora rds parameter map"
  type        = map(string)
}

variable "tags" {
  description = "tag map"
  type        = map(string)
}