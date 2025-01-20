provider "aws" {
  region = var.region_name
}

terraform {
  backend "s3" {
    bucket = "terraform-s3-jnaneshwar"
    key    = "s3-bucket.tfstate"
    region = "us-east-1"
  }
}



resource "aws_vpc" "Terraform_vpc" {
  cidr_block    = var.vpc_cidr_block
  instance_tenancy = "default"

  tags = {
    Name =  var.vpc_tag
  }
}

resource "aws_internet_gateway" "Terraform_vpc_igw" {
  vpc_id = aws_vpc.Terraform_vpc.id

  tags = {
    Name =  var.igw_tag
  }
}

resource "aws_subnet" "Terraform_vpc_subnet" {
  vpc_id     = aws_vpc.Terraform_vpc.id
  cidr_block = var.subnet_cidr_block

  tags = {

    Name = var.subnet_tag
  }

}

resource "aws_route_table" "Terraform_vpc_rt" {
  vpc_id = aws_vpc.Terraform_vpc.id

  route {
    cidr_block = var.rt_cidr_block
    gateway_id = aws_internet_gateway.Terraform_vpc_igw.id
  }
}

resource "aws_route_table_association" "Terraform_vpc_rta" {
  subnet_id      = aws_subnet.Terraform_vpc_subnet.id
  route_table_id = aws_route_table.Terraform_vpc_rt.id
}

resource "aws_security_group" "allow_all" {
    vpc_id      = aws_vpc.Terraform_vpc.id

    ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" 
    }

     egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
     }

     tags = {
    Name = "Terraform_vpc_allow_all"
  }
}

resource "aws_instance"   "web-1" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = var.ec2_type
  key_name      = var.key_name
  subnet_id     = aws_subnet.Terraform_vpc_subnet.id
  vpc_security_group_ids = ["${aws_security_group.allow_all.id}"]
  associate_public_ip_address = true

  tags = {
    Name = "web-1"
  }
}
