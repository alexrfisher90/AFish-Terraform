  resource "aws_instance" "terraec2" {
  ami = data.aws_ssm_parameter.instance_ami.value
  instance_type = "t2.micro"
  key_name = "AFishK"
  subnet_id = aws_subnet.pubsub[0].id
  vpc_security_group_ids = [aws_default_security_group.terrasg.id]
  tags = {
    "Name" = "${var.default_tags.env}-EC2"
  }
    user_data = base64encode(file("user.sh"))

} 