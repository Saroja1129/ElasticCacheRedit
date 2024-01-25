provider "aws" {
  region = "us-east-2"
}

#Vpc
resource "aws_vpc" "Saroja_Hibernate_Vpc" {
  cidr_block = "192.168.0.0/27"
  tags = {
    Name = "Saroja Hibernate VPC"
  }
}

#Subnet
resource "aws_subnet" "Hibernate_Public_Subnet" {
  vpc_id                  = aws_vpc.Saroja_Hibernate_Vpc.id
  availability_zone       = "us-east-2a"
  cidr_block              = "192.168.0.0/28"
  map_public_ip_on_launch = true
  tags = {
    Name = "Saroja Hibernate Public Subnet"
  }
}

#Route Table
resource "aws_route_table" "Hibernate_Public_RT" {
  vpc_id = aws_vpc.Saroja_Hibernate_Vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.Hibernate_IGW.id
  }

  tags = {
    Name = "Hibernate Public Route Table"
  }
}


#Internet Gateway
resource "aws_internet_gateway" "Hibernate_IGW" {
  vpc_id = aws_vpc.Saroja_Hibernate_Vpc.id
}

#Elastic IP
resource "aws_eip" "Hibernate_eip" {
  vpc = true
}

#NACL
resource "aws_network_acl" "Hibernate_NACl" {
  vpc_id = aws_vpc.Saroja_Hibernate_Vpc.id
  tags = {
    Name = "Saroja Hibernate NACL"
  }

}

#Security Groups
resource "aws_security_group" "Saroja_Hibernate_Windows_SG" {
  vpc_id = aws_vpc.Saroja_Hibernate_Vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3389
    to_port     = 3389
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# Ec2 instance
resource "aws_instance" "Saroja_Hibenate_EC2" {
  ami                         = "ami-0b24eb32c43d56c23"
  instance_type               = "t2.medium"
  subnet_id                   = aws_subnet.Hibernate_Public_Subnet.id
  vpc_security_group_ids      = [aws_security_group.Saroja_Hibernate_Windows_SG.id]
  associate_public_ip_address = true

  key_name = "Saroja December AWS Key"

  tags = {
    Name = "Saroja Hibernate Windows"
  }

}

resource "aws_route_table_association" "Hibernate_public_assoc" {
  subnet_id      = aws_subnet.Hibernate_Public_Subnet.id
  route_table_id = aws_route_table.Hibernate_Public_RT.id

}

#Output

output "public_ip" {
  value = aws_instance.Saroja_Hibenate_EC2.public_ip
}


