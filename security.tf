resource "aws_security_group" "terrasg" {
    name = "terrasg"
    description = "SG for demo"
    vpc_id = aws_vpc.terravpc.id
    ingress {
        description = "All In"
        from_port = SSH 
        to_port = SSH
        protocol = TCP
    }
  
}