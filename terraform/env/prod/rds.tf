# KMS Key for RDS encryption
resource "aws_kms_key" "rds" {
  description             = "KMS key for RDS MySQL encryption"
  deletion_window_in_days = 7

  tags = {
    Name        = "gsn-carrot-rds-kms"
    Environment = "prod"
    Terraform   = "true"
  }
}

resource "aws_kms_alias" "rds" {
  name          = "alias/gsn-carrot-rds"
  target_key_id = aws_kms_key.rds.key_id
}

# Secrets Manager for DB credentials
resource "aws_secretsmanager_secret" "db_credentials" {
  name                    = "gsn-carrot-db-credentials"
  description             = "Database credentials for GSN Carrot MySQL"
  recovery_window_in_days = 7

  tags = {
    Name        = "gsn-carrot-db-credentials"
    Environment = "prod"
    Terraform   = "true"
  }
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.main.endpoint
    port     = aws_db_instance.main.port
    dbname   = aws_db_instance.main.db_name
  })
}

# Security Group for RDS
resource "aws_security_group" "rds" {
  name        = "gsn-carrot-rds-sg"
  description = "Security group for RDS MySQL"
  vpc_id      = module.vpc.vpc_id

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [module.eks.node_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "gsn-carrot-rds-sg"
    Environment = "prod"
    Terraform   = "true"
  }
}

# DB Subnet Group for RDS
resource "aws_db_subnet_group" "main" {
  name       = "gsn-carrot-db-subnet-group"
  subnet_ids = module.vpc.private_subnets

  tags = {
    Name        = "gsn-carrot-db-subnet-group"
    Environment = "prod"
    Terraform   = "true"
  }
}

# RDS MySQL Instance
resource "aws_db_instance" "main" {
  identifier = "gsn-carrot-mysql"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.medium"

  allocated_storage     = 20
  max_allocated_storage = 100
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.rds.arn

  db_name  = "carrot"
  username = var.db_username
  password = var.db_password

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name

  backup_retention_period = 7
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"

  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name        = "gsn-carrot-mysql"
    Environment = "prod"
    Terraform   = "true"
  }
}
