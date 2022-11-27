# terraform-aws-module-rds-aurora
* Aurora RDS를 생성하는 공통 모듈

v1.0.3 => aws_db_cluster에 cloud watch log 기능 추가

## Usage

### `terraform.tfvars`
* 모든 변수는 적절하게 변경하여 사용
```
account_id   = "123456789012"
region       = "ap-northeast-2"
prefix       = "test"
cluster_name = "kcl"

engine         = "aurora-mysql"
engine_version = "8.0.mysql_aurora.3.02.0"
engine_mode    = "provisioned"

# 필독!! 이름 정의 규칙 반드시 확인 필요
# DB cluster identifier => ${var.prefix}-${var.cluster_name}-${var.engine}
# DB Subnet Groups      => ${var.prefix}-${var.cluster_name}-${var.engine}-subnet-groups

azs = ["ap-northeast-2a", "ap-northeast-2c"] # 3개의 AZ를 적어야 함, 2개만 적용하려면 다음 apply에 AZ를 강제 추가 되기 때문에 ignore_changes 필요

database_name   = "kcl"
master_username = "admin"
port            = "3306"

backup_retention_period      = "7"
preferred_backup_window      = "07:00-09:00"
preferred_maintenance_window = ""
auto_minor_version_upgrade   = false

replica_count  = "2" # (1) writer only, (2) writer + 1 reader, (3) writer + 2 readers, (4) ...
instance_class = "db.r5.large"

deletion_protection = true # 테스트에서만 false로 사용, prod에서는 true 변경!!
skip_final_snapshot = true

kms_key_id        = "abcdefghijklmn1234567" # 대칭키, 싱글리전
storage_encrypted = true # kms를 사용하기 위해 기본 true로 되어야 함

vpc_filters = {
  "Name" = "kcl-vpc"
}

private_subnet_filters = {
  "Name" = [ "kcl-rds-aurora-subnet-2a", "kcl-rds-aurora-subnet-2c" ]
}

security_group_filters = {
  "Name" = [ "kcl-rds-aurora-security-groups" ]
}

# cloud watch로 로그 게시
enabled_cloudwatch_logs_exports = ["audit", "error", "general", "slowquery"]
# mysql => "audit", "error", "general", "slowquery" (감사로그, 에러로그, 일반로그, 느린쿼리로그)
# postgresql => "postgresql"

tags = {
    "CreatedByTerraform"     = "true"
    "TerraformModuleName"    = "terraform-aws-module-rds-aurora"
    "TerraformModuleVersion" = "v1.0.3"
}

########################
# Parameter setting link
########################
# Aurora MySQL => https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/AuroraMySQL.Reference.html

# Cluster Parameter Group Setting
cluster_parameter_group_name 	 = "kcl-aurora-mysql"
cluster_parameter_group_family = "aurora-mysql8.0"

# cluster parameter는 Cluster-level의 parameter를 작성하는 곳이며, 상단 링크를 참고하여 "key"="value"형태로 작성
cluster_parameter = {
  "character_set_server"     = "utf8mb4"
  "character_set_client"     = "utf8mb4"
  "character_set_connection" = "utf8mb4"
  "character_set_database"   = "utf8mb4"
  "character_set_filesystem" = "utf8mb4"
  "character_set_results"    = "utf8mb4"
  "collation_connection"     = "utf8mb4_general_ci"
  "collation_server"         = "utf8mb4_general_ci"
  "time_zone"                = "Asia/Seoul"
}

# Parameter Group Setting
parameter_group_name 	 = "kcl-aurora-mysql"
parameter_group_family = "aurora-mysql8.0"

# Parameter는 Instance-level의 parameter를 작성하는 곳이며, 상단 링크를 참고하여 "key"="value"형태로 작성
parameter = {
  #"parameter name" = "value"
}

###################################################################################################
# Option setting
###################################################################################################
#
# Aurora의 경우 Option Group을 정의 할 수 없음
#
```
---

### `main.tf`
```
module "rds-aurora" {
  source = "git::https://github.comaws-rds-aurora-module.git?ref=v1.0.3"
  
  account_id   = var.account_id
  region       = var.region
  prefix       = var.prefix
  cluster_name = var.cluster_name

  engine         = var.engine
  engine_version = var.engine_version
  engine_mode    = var.engine_mode
  
  port            = var.port
  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.aurora_mysql_password

  backup_retention_period           = var.backup_retention_period
  preferred_backup_window           = var.preferred_backup_window
  preferred_maintenance_window      = var.preferred_maintenance_window
  auto_minor_version_upgrade        = var.auto_minor_version_upgrade
  deletion_protection               = var.deletion_protection
  skip_final_snapshot               = var.skip_final_snapshot
  enabled_cloudwatch_logs_exports   = var.enabled_cloudwatch_logs_exports


  kms_key_id        = var.kms_key_id
  storage_encrypted = var.storage_encrypted
  
  replica_count  = var.replica_count
  instance_class = var.instance_class

  azs                    = var.azs
  vpc_id                 = data.aws_vpc.this.id
  subnet_ids             = data.aws_subnet_ids.private.ids
  vpc_security_group_ids = data.aws_security_groups.this.ids

  current_id     = data.aws_caller_identity.current.account_id
  current_region = data.aws_region.current.name

  tags = var.tags
  
  # Cluster Parameter Group Setting
  cluster_parameter_group_name	 = var.cluster_parameter_group_name
  cluster_parameter_group_family = var.cluster_parameter_group_family   
  cluster_parameter              = var.cluster_parameter    
  
  # DB Parameter Group Setting
  parameter_group_name 	 = var.parameter_group_name
  parameter_group_family = var.parameter_group_family   
  parameter              = var.parameter    
}
```
---

### `provider.tf`
```
provider "aws" {
  region = var.region
}
```
---

### `terraform.tf`
```
terraform {
  required_version = ">= 1.1.2"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 3.71"
    }
  }

  backend "s3" {
    bucket         = "kcl-tf-state-backend"
    key            = "012345678912/rds-aurora/terraform.state"
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-state-locks"
    encrypt        = true
  }
}
```
---

### `data.tf`
```
data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "this" {
  dynamic "filter" {
    for_each = var.vpc_filters
    iterator = tag
    content {
      name   = "tag:${tag.key}"
      values = [tag.value]
    }
  }
}

data "aws_subnet_ids" "private" {
  vpc_id = data.aws_vpc.this.id
  dynamic "filter" {
    for_each = var.private_subnet_filters
    iterator = tag
    content {
      name   = "tag:${tag.key}"
      values = "${tag.value}"
    }
  }
}

data "aws_security_groups" "this" {
  dynamic "filter" {
    for_each = var.security_group_filters
    iterator = tag
    content {
      name   = "tag:${tag.key}"
      values = "${tag.value}"
    }
  }
}
```
---

### `variables.tf`
```
variable "region" {
  description = "AWS Region"
  type        = string
}

variable "account_id" {
  description = "List of Allowed AWS account IDs"
  type        = string
}

variable "vpc_filters" {
  description = "Filters to select subnets"
  type        = map(string)
}

variable "private_subnet_filters" {
  description = "Filters to select private subnets"
  type        = map(list(string))
}

variable "security_group_filters" {
  description = "A list of security group IDs to associate with."
  type        = map(list(string))
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

variable "database_name" {
  description = "RDS Aurora Database Name"
  type        = string
}

variable "master_username" {
  description = "RDS Aurora Master User Name"
  type        = string
}

variable "aurora_mysql_password" {
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


variable "replica_count" {
  description = "RDS Aurora Multi AZ"
  type        = string
}

variable "instance_class" {
  description = "RDS Aurora Intance Type"
  type        = string
}

variable "deletion_protection" {
  description = "RDS Aurora Instances Deletion Protection"
  type        = bool
}

variable "skip_final_snapshot" {
  description = "RDS Aurora Deletion Protection"
  type        = bool
}

variable "kms_key_id" {
  description = "kms key"
  type        = string
}

variable "storage_encrypted" {
  description = "aurora rds encrypted using kms"
  type        = bool
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
  default     = {}
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
  default     = {}
}

variable "tags" {
  description = "tag map"
  type        = map(string)
}
```
---

### `outputs.tf`
```
output "rds-aurora" {
  description = "AWS RDS Aurora"
  value       = module.rds-aurora 
}
```

## 실행방법
```
terraform init -get=true -upgrade -reconfigure
terraform validate (option)
terraform plan -var-file=terraform.tfvars -refresh=false -out=planfile
terraform apply planfile
```
* "Objects have changed outside of Terraform" 때문에 `-refresh=false`를 사용
* 실제 UI에서 리소스 변경이 없어보이는 것과 low-level Terraform에서 Object 변경을 감지하는 것에 차이가 있는 것 같음, 다음 링크 참고
  * https://github.com/hashicorp/terraform/issues/28776
* 위 이슈로 변경을 감지하고 리소스를 삭제하는 케이스가 발생 할 수 있음