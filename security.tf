resource "aws_default_security_group" "terrasg" {
  vpc_id = aws_vpc.terravpc.id

  #Inbound Rules
  ingress {
    description = "All in"
    from_port   = 0
    to_port     = 0
    protocol    = "TCP"
    self        = true
  }
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "TCP"
    cidr_blocks = ["0.0.0.0/0"]
  }

  #Outbound Rules
  egress {
    description = "Allow All"
    from_port   = 0
    to_port     = 0
    protocol    = -1
  }
}