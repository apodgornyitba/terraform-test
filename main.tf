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