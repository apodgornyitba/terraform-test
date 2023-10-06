# output "bucket_name" {
#   description = "Nombre del bucket"
#   value = aws_s3_bucket.main.id

# }

# output "bucket_all" {
#   description = "Todos los atrivutos del bucket"
#   value = aws_s3_bucket.main

# }

output "vpc-info" {
  description = "value of vpc cidr"
  value = {
    cidr_block = aws_vpc.main.cidr_block
    id         = aws_vpc.main.id
  }
}

output "subnets-ids" {
  description = "value of subnets ids"
  value = {
    pub-1 = aws_subnet.public-subnets[0].id
    pub-2 = aws_subnet.public-subnets[1].id
  }
}