provider "aws" {
region = "us-east-1"  
}

variable "cidr" {
    default = "10.0.0.0/16"
}
resource "aws_key_pair" "deployer_key" {
  key_name   = "key-1"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_vpc" "main-1" {
  cidr_block = var.cidr
}
resource "aws_subnet" "sub-1" {
  vpc_id     = aws_vpc.main-1.id
  cidr_block = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone = "us-east-1a"
}
resource "aws_internet_gateway" "igw" {
      vpc_id = aws_vpc.main-1.id 
}
resource "aws_route_table" "RT" {
  vpc_id = aws_vpc.main-1.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}
resource "aws_route_table_association" "route_association-1" {
  subnet_id      = aws_subnet.sub-1.id
  route_table_id = aws_route_table.RT.id
}
resource "aws_security_group" "web_sg-1" {
  name        = "security-group-1"
  vpc_id      = aws_vpc.main-1.id # Reference to an existing VPC

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP from anywhere
    description = "HTTP from VPC"
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTPS from anywhere
    description = "SSH"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # Allow all protocols
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
    description = "Allow all outbound traffic"
  }
  tags = {
    Name = "WebSecurityGroup"
  }
}
resource "aws_instance" "example-1" {
  ami = "ami-0360c520857e3138f"
  key_name = aws_key_pair.deployer_key.id
  instance_type = "t3.micro"
  subnet_id = aws_subnet.sub-1.id
  vpc_security_group_ids = [aws_security_group.web_sg-1.id]
  
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("~/.ssh/id_rsa")
    host        = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install apache2 -y",
      "sudo chmod -R 775 /var/www/html",
      "sudo chown -R ubuntu:ubuntu /var/www/html",
      "cd /var/www/html &"
    ]
     
  }
  provisioner "file" {
    source = "index.html"
    destination = "/var/www/html/index.html"
  }
}

output "public_ip" {
  value =aws_instance.example-1.public_ip
}