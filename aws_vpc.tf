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
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

