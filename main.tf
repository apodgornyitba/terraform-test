# ----------------------------------------------------------------------------------
# -------------------------------EJ1-NETWORKING-------------------------------------
# ----------------------------------------------------------------------------------


# resource "aws_subnet" "private" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.1.0/24"
# #   availability_zone = "us-east-1a"

#   tags = {
#     Name = "Main"
#   }

# }

# resource "aws_subnet" "public" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.1.0/24"
# #   availability_zone = "us-east-1a"

#   tags = {
#     Name = "Main"
#   }

# }

# resource "aws_s3_bucket" "main" {
#   bucket        = var.bucket_name
#   force_destroy = "true"

#   tags = {
#     Name        = var.bucket_name
#     Environment = "Dev"
#   }
# }

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"


  tags = {
    Name = var.vpc_name
  }
}

# resource "aws_subnet" "pub-1" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.1.0/24"
#   availability_zone = "us-east-1a"

#   tags = {
#     Name = "${var.subnet_name}1"
#   }
# }

# resource "aws_subnet" "pub-2" {
#   vpc_id     = aws_vpc.main.id
#   cidr_block = "10.0.2.0/24"
#   availability_zone = "us-east-1b"

#   tags = {
#     Name = "${var.subnet_name}2"
#   }
# }

resource "aws_subnet" "public-subnets" {
  count      = length(var.public_subnet_cidr_suffixes)
  vpc_id     = aws_vpc.main.id
  cidr_block = cidrsubnet(var.public_subnet_cidr_base, 8, var.public_subnet_cidr_suffixes[count.index])

  availability_zone = var.azs[count.index]

  tags = {
    Name = "${var.subnet_name}${count.index + 1}"
  }

}

resource "aws_internet_gateway" "igw-1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = var.internet_gateway_name
  }
}

resource "aws_route_table" "rtb-1" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw-1.id
  }

  tags = {
    Name = var.route_table_name
  }
}

resource "aws_route_table_association" "rtb-assoc-1" {
  count          = length(var.public_subnet_cidr_suffixes)
  subnet_id      = aws_subnet.public-subnets[count.index].id
  route_table_id = aws_route_table.rtb-1.id
}

# ----------------------------------------------------------------------------------
# -------------------------------EJ2-COMPUTE----------------------------------------
# ----------------------------------------------------------------------------------

resource "aws_instance" "pub-ec2-1" {
  ami           = "ami-0022f774911c1d690"
  subnet_id     = aws_subnet.public-subnets[0].id
  instance_type = "t2.micro"
  user_data     = <<-EOF
              #!/bin/bash
              yum install -y httpd
              echo "<html><body><h1>Hello, World!</h1></body></html>" > /var/www/html/index.html
              sed -i 's/Listen 80/Listen 0.0.0.0:80/' /etc/httpd/conf/httpd.conf
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "${var.ec2_instance_name}1"
  }
}

resource "aws_instance" "pub-ec2-2" {
  ami           = "ami-0022f774911c1d690"
  subnet_id     = aws_subnet.public-subnets[1].id
  instance_type = "t2.micro"
  user_data     = <<-EOF
              #!/bin/bash
              yum install -y httpd
              echo "<html><body><h1>Hello, World!</h1></body></html>" > /var/www/html/index.html
              sed -i 's/Listen 80/Listen 0.0.0.0:80/' /etc/httpd/conf/httpd.conf
              systemctl start httpd
              systemctl enable httpd
              EOF

  tags = {
    Name = "${var.ec2_instance_name}2"
  }
}

resource "aws_security_group" "allow_tcp" {
  name        = var.security_group_name
  description = "Allow TCP traffic"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "TCP from VPC"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block, aws_subnet.public-subnets[0].cidr_block, aws_subnet.public-subnets[1].cidr_block]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}