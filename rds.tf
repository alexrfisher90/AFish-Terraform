#security
module "sg_db" {
  source        = "./modules/rds"
  sg_name       = "${var.default_tags.env}-db-sg"
  description   = "DB SG Terraform"
  vpc_id        = aws_vpc.terravpc.id
  sg_db_ingress = var.sg_db_ingress
  sg_db_egress  = var.sg_db_egress
  sg_source     = aws_instance.terraec2.vpc_security_group_ids
}
#db subnet group
resource "aws_db_subnet_group" "db" {
  name_prefix = "afish-terrards"
  subnet_ids  = aws_subnet.prisub.*.id
  tags = {
    Name = "${var.default_tags.env}-group"
  }
}
#cluster
resource "aws_rds_cluster" "db" {
  cluster_identifier     = "${var.default_tags.env}-db-cluster"
  db_subnet_group_name   = aws_db_subnet_group.db.name
  engine                 = "aurora-mysql"
  availability_zones     = aws_subnet.prisub[*].availability_zone
  engine_version         = "5.7.mysql_aurora.2.11.1"
  database_name          = "afdb"
  vpc_security_group_ids = [module.sg_db.sg_id]
  master_username        = var.db_credentials.username
  master_password        = var.db_credentials.password
  skip_final_snapshot    = true
  tags = {
    Name = "${var.default_tags.env}-cluster"
  }
}
#cluster instances
resource "aws_rds_cluster_instance" "db" {
  count                = 2
  identifier           = "${var.default_tags.env}-${count.index}"
  cluster_identifier   = aws_rds_cluster.db.id
  instance_class       = "db.t3.medium"
  engine               = aws_rds_cluster.db.engine
  engine_version       = aws_rds_cluster.db.engine_version
  db_subnet_group_name = aws_db_subnet_group.db.name
}
output "db_endpoints" {
  value = {
    writer = aws_rds_cluster.db.endpoint
    reader = aws_rds_cluster.db.reader_endpoint
  }
}