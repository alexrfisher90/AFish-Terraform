resource "aws_rds_cluster" "terrards" {
  cluster_identifier      = "afish-terrards"
  engine                  = "aurora-mysql"
  availability_zones      = ["us-east-1a", "us-east-1b"]
  database_name           = "terradb"
  master_username         = "afish"
  master_password         = "afishpassword"
  backup_retention_period = 5
  preferred_backup_window = "07:00-09:00"
}