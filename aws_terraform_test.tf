#For snyk test
#

resource "aws_vpc" "snyk_test_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
}

resource "aws_subnet" "snyk_test_subnet" {
  vpc_id                  = aws_vpc.snyk_test_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "snyk_test_igw" {
  vpc_id = aws_vpc.snyk_test_vpc.id
}

resource "aws_route_table" "snyk_test_rtb" {
  vpc_id = aws_vpc.ssnyk_test_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.snyk_test_igw.id
  }
}

resource "aws_route_table_association" "snyk_test_rt_assoc" {
  subnet_id      = aws_subnet.snyk_test_subnet.id
  route_table_id = aws_route_table.snyk_test_rtb.id
}

#SG is full open for snyk test
#

resource "aws_security_group" "snyk_test_sg" {
  name   = "snyk_test-sg"
  vpc_id = aws_vpc.snyk_test_vpc.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_instance" "snyk_test_ec2" {
  ami                    = "ami-09d28faae2e9e7138"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.snyk_test_subnet.id
  vpc_security_group_ids = [aws_security_group.snyk_test_sg.id]
  user_data              = <<EOF
#! /bin/bash
sudo yum install -y httpd
sudo systemctl start httpd
sudo systemctl enable httpd
EOF
}


resource "aws_db_instance" "snyk_test_rds" {
  identifier             = "snyk_test_rds"
  db_name                = "test"
  allocated_storage      = 20
  storage_type           = "gp2"
  engine                 = "mysql"
  engine_version         = "5.7"
  instance_class         = "db.t3.medium"
  username               = "test"
  password               = "password"
  db_subnet_group_name   = aws_db_subnet_group.dev-subnet-group.name
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.snyk_test_sg.id]
}


resource "aws_db_subnet_group" "dev-subnet-group" {
  name       = "dev-subnet-group"
  subnet_ids = [aws_subnet.snyk_test_subnet.id]
}
