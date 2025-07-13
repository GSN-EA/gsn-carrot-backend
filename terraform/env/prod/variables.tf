variable "allowed_cidrs" {
  description = "Allowed CIDR blocks for EKS API server access"
  type        = list(string)
  sensitive   = true
}

variable "db_password" {
  description = "Database password for RDS MySQL"
  type        = string
  sensitive   = true
}

variable "db_username" {
  description = "Database username for RDS MySQL"
  type        = string
  default     = "admin"
  sensitive   = true
}
