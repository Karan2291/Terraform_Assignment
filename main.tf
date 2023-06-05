# Networking
resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Custom VPC"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public Subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"

  tags = {
    Name = "Private Subnet"
  }
}

# SSH-Key
resource "tls_private_key" "ssh_key" {
  algorithm = "RSA"
}

resource "aws_key_pair" "ssh_key_pair" {
  key_name   = "ssh-key"
  public_key = tls_private_key.ssh_key.public_key_openssh
}

# EC2
resource "aws_instance" "public_vm" {
  ami           = "ami-abc123"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key_pair.key_name
  subnet_id     = aws_subnet.public_subnet.id

  tags = {
    Name = "Public VM"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx"
    ]
  }
}

resource "aws_instance" "private_vm" {
  ami           = "ami-xyz789"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.ssh_key_pair.key_name
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name = "Private VM"
  }

   provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx",
      "sudo systemctl start nginx"
    ]
  }
}