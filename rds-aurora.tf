resource "null_resource" "validate_account" {
  count = var.current_id == var.account_id ? 0 : "Please check that you are using the AWS account"
}

resource "null_resource" "validate_module_name" {
  count = local.module_name == var.tags["TerraformModuleName"] ? 0 : "Please check that you are using the Terraform module"
}

resource "null_resource" "validate_module_version" {
  count = local.module_version == var.tags["TerraformModuleVersion"] ? 0 : "Please check that you are using the Terraform module"
}

resource "aws_rds_cluster" "this" {
  cluster_identifier   = format("%s-%s-%s", var.prefix, var.cluster_name, var.engine)
  db_subnet_group_name = aws_db_subnet_group.this.name

  engine         = var.engine
  engine_version = var.engine_version
  engine_mode    = var.engine_mode

  availability_zones = var.azs
  database_name   = var.database_name
  master_username = var.master_username
  master_password = var.master_password

  backup_retention_period         = var.backup_retention_period
  preferred_backup_window         = var.preferred_backup_window
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports

  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot
  
  kms_key_id        = format("arn:aws:kms:%s:%s:key/%s", var.region, var.account_id, var.kms_key_id)
  storage_encrypted = var.storage_encrypted

  vpc_security_group_ids          = var.vpc_security_group_ids
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.this.name

  lifecycle {
    create_before_destroy = true
    ignore_changes = [
      master_password,
      availability_zones
    ]
  }

  depends_on = [
    aws_db_subnet_group.this
  ]

  tags = merge(var.tags, tomap({Name = format("%s-%s-%s", var.prefix, var.cluster_name, var.engine)}))
}

resource "aws_rds_cluster_instance" "this" {
  count = var.replica_count

  identifier         = format("%s-%s-%s-%s", var.prefix, var.cluster_name, var.engine, "${count.index}")
  cluster_identifier = aws_rds_cluster.this.id

  db_subnet_group_name    = aws_db_subnet_group.this.name
  db_parameter_group_name = aws_db_parameter_group.this.name

  instance_class = var.instance_class
  engine         = aws_rds_cluster.this.engine
  engine_version = aws_rds_cluster.this.engine_version

  auto_minor_version_upgrade      = var.auto_minor_version_upgrade
  

  tags = merge(var.tags, tomap({Name = format("%s-%s-%s-%s", var.prefix, var.cluster_name, var.engine, "${count.index}")}))

  depends_on = [
    aws_rds_cluster.this
  ]
}

resource "aws_db_subnet_group" "this" {
  name = format("%s-%s-%s-subnet-groups", var.prefix, var.cluster_name, var.engine)
  subnet_ids = var.subnet_ids

  tags = merge(var.tags, tomap({Name = format("%s-%s-%s-subnet-groups", var.prefix, var.cluster_name, var.engine)}))
}

resource "aws_rds_cluster_parameter_group" "this" {
  name    = format("%s-cluster-parameter-groups", var.cluster_parameter_group_name)
  family  = var.cluster_parameter_group_family

  dynamic parameter {
    for_each = var.cluster_parameter
    
    content {
      name  = parameter.key
      value = parameter.value
    }
  }
  tags = merge(var.tags, tomap({Name = format("%s-cluster-parameter-groups", var.cluster_parameter_group_name)}))
}

resource "aws_db_parameter_group" "this" {
  name    = format("%s-parameter-groups", var.parameter_group_name)
  family  = var.parameter_group_family

  dynamic parameter {
    for_each = var.parameter

    content {
      name  = parameter.key
      value = parameter.value
    }
  }
  tags = merge(var.tags, tomap({Name = format("%s-parameter-groups", var.parameter_group_name)}))
}
