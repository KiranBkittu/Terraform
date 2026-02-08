provider "aws"{
    region = "us-east-1"  
}
resource "aws_instance" "ex-1" {
  ami           = var.ami_value # Amazon Linux 2 AMI (HVM), SSD Volume Type
  instance_type = var.instance_type_value
  key_name      = var.key_name_value
  tags = {
    Name = var.instance_name_value
  }
}