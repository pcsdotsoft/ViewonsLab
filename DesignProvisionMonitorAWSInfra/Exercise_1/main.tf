#Designate a cloud provider, region, and credentials

provider "aws" {
  region     = "us-east-1"
  # credentials use AWS_PROFILE environment var
}
variable "PublicSubnet1CIDR" { 
    description = "PublicSubnet1CIDR"
}

data "aws_ami" "amzn2" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }
}

resource "aws_vpc" "udatf-vpc" {
  cidr_block = "10.1.0.0/16"
  tags = {
    Name = "Udacity VPC"
  }
}

resource "aws_subnet" "PublicSubnet1" {
  vpc_id            = aws_vpc.udatf-vpc.id
  cidr_block        = var.PublicSubnet1CIDR.cidr_block
  availability_zone = "us-east-1a"

  tags = {
    Name = var.PublicSubnet1CIDR.name
  }
}

resource "aws_internet_gateway" "udatf-igw" {
  vpc_id = aws_vpc.udatf-vpc.id
}

resource "aws_route_table" "udatf-rt" {
  vpc_id = aws_vpc.udatf-vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.udatf-igw.id
  }
  tags = {
    Name = "udatf-rt"
  }
}

resource "aws_route_table_association" "rtsubnetassociation" {
    subnet_id      = aws_subnet.PublicSubnet1.id
    route_table_id = aws_route_table.udatf-rt.id
}


resource "aws_security_group" "ssh_sg" {
    name        = "ssh_sg"
    description = "ssh_sg"
    vpc_id      = aws_vpc.udatf-vpc.id

    ingress {
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = ["0.0.0.0/0"]
      from_port = 22
      to_port     = 22
    }
    egress {
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
      from_port   = 0
      to_port     = 0
    }

    tags = {
      Name = "ssh_sg"
    }
}

# provision 4 AWS t2.micro EC2 instances named Udacity T2
resource "aws_instance" "udaT2" {
    count = 4
    ami = data.aws_ami.amzn2.id
    instance_type = "t2.micro"
    availability_zone = "us-east-1a"
    key_name = "udatfkey"
    associate_public_ip_address = true
    subnet_id = aws_subnet.PublicSubnet1.id
    security_groups = [aws_security_group.ssh_sg.id]
    tags = {
        Name = "Udacity-T2-${count.index}"
    }
}



# TODO: provision 2 m4.large EC2 instances named Udacity M4
resource "aws_instance" "udaM4" {
    count = 2
    ami = data.aws_ami.amzn2.id
    instance_type = "m4.large"
    availability_zone = "us-east-1a"
    key_name = "udatfkey"
    associate_public_ip_address = true
    subnet_id = aws_subnet.PublicSubnet1.id
    security_groups = [aws_security_group.ssh_sg.id]
    tags = {
        Name = "Udacity-M4-${count.index}"
    }
}