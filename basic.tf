# Creates VPC with one public and one private subnet.
# Creates a internet gateway with route to internet
# Creates a basic security group allowing SSH access


provider "aws" {
    region = "us-east-1"
    access_key = "<key>"
    secret_key = "<key>"
}

resource "aws_vpc" "main" {
    cidr_block = "10.1.0.0/16"
    tags = {
        Name = "Terraform VPC"
    }
}

resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "Terraform-ig"
    }
}

resource "aws_subnet" "public" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.1.1.0/24"
    availability_zone = "us-east-1a"
    map_public_ip_on_launch = true
    tags = {
        Name = "Terraform Public Subnet"
    }
}

resource "aws_subnet" "private" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.1.2.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "Terraform Private Subnet"
    }
}

resource "aws_route_table" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "Terraform Route Table"
    }
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.main.id
    }
}

resource "aws_route_table_association" "main"{
    subnet_id = aws_subnet.public.id
    route_table_id = aws_route_table.main.id
}

resource "aws_security_group" "allowall" {
    name = "Terraform SG Allow All"
    description = "Allows all traffic to port 22"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
        }
    
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}