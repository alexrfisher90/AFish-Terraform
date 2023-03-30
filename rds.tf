#security
module "sg_db" {
  source = "./modules/rds"
  sg_name = "${var.default_tags.env}-db-sg"
  description = "DB SG Terraform"
  vpc_id = aws_vpc.terravpc.id
  sg_db_ingress = var.sg_db_ingress
  sg_db_egress = var.sg_db_egress
  sg_source = aws_instance.terraec2.vpc_security_group_ids
}
#db subnet group
#cluster
#cluster instances