# Security Group for Database Tier
resource "aws_security_group" "db" {
  name_prefix = "db-tier-sg"
  vpc_id      = var.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [var.app_sg_id]
  }

  tags = merge(var.project_tags, {
    Name = "db-tier-sg"
  })
}

# DB Subnet Group
resource "aws_db_subnet_group" "aurora" {
  name       = "aurora-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = merge(var.project_tags, {
    Name = "aurora-subnet-group"
  })
}

# Aurora Cluster
resource "aws_rds_cluster" "aurora" {
  cluster_identifier     = "three-tier-aurora"
  engine                = "aurora-mysql"
  engine_version        = "5.7.mysql_aurora.2.11.2"
  database_name         = var.db_name
  master_username       = var.db_username
  master_password       = var.db_password
  db_subnet_group_name  = aws_db_subnet_group.aurora.name
  vpc_security_group_ids = [aws_security_group.db.id]
  skip_final_snapshot   = true

  availability_zones    = [
    data.aws_availability_zones.available.names[0],
    data.aws_availability_zones.available.names[1]
  ]

  tags = merge(var.project_tags, {
    Name = "aurora-cluster"
  })
}

# Aurora Instances
resource "aws_rds_cluster_instance" "aurora_instances" {
  count               = 2
  identifier          = "three-tier-aurora-${count.index + 1}"
  cluster_identifier  = aws_rds_cluster.aurora.id
  instance_class      = "db.t3.medium"
  engine              = aws_rds_cluster.aurora.engine
  engine_version      = aws_rds_cluster.aurora.engine_version

  tags = merge(var.project_tags, {
    Name = "aurora-instance-${count.index + 1}"
  })
}

# Data source for AZs
data "aws_availability_zones" "available" {
  state = "available"
}
