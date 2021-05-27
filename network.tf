
resource "aws_security_group" "wireguard_ssh_check" {
  name   = "justin-wireguard_ssh_check"
  vpc_id = aws_vpc.justin-wireguard-vpc.id

  # SSH access from the CIDR, which allows our healthcheck to complete
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/24"] # range that covers public subnet_ids, aws_lb will check the hosts from these ranges
  }
}

resource "aws_eip" "wireguard" {
  instance = aws_instance.justin-wireguard-instance.id
  vpc = true
  tags = {
    name        = "justin-wireguard-EIP"
  }
}

resource "aws_vpc" "justin-wireguard-vpc" {  
  cidr_block = "10.0.0.0/16"

  tags = {
    name        = "justin-wireguard-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.justin-wireguard-vpc.id
}

resource "aws_route_table" "aws-route-table" {
  vpc_id = aws_vpc.justin-wireguard-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

}

resource "aws_subnet" "wg-subnet" {
  vpc_id     = aws_vpc.justin-wireguard-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "justin-wg-subnet"
  }
}

resource "aws_route_table_association" "route-table-association" {
    subnet_id = aws_subnet.wg-subnet.id
    route_table_id = aws_route_table.aws-route-table.id
}